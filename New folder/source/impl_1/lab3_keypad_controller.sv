module lab3_keypad_controller (
    input logic        clk,
    input logic        reset,

    input logic [3:0]  keypad_col,

    output logic [3:0] keypad_row,

    output logic [3:0] key,
    output logic       key_valid
);

    logic [3:0] synchronized_col;

    logic [15:0] key_matrix;
    logic        scan_complete;

    // Synchronize keypad columns

    lab3_synchronizer i_synchronizer (
        .clk(clk),
        .reset(reset),
        .async_signal(keypad_col),
        .sync_signal(synchronized_col)
    );


    // Scan keypad

    lab3_scanner i_scanner (
        .clk(clk),
        .reset(reset),
        .keypad_col(synchronized_col),
        .keypad_row(keypad_row),
        .key_matrix(key_matrix),
        .scan_complete(scan_complete)
    );

    // FSM

    typedef enum logic [2:0] {
        WAITING				=3'b000,
        DEBOUNCING			=3'b001,
        SINGLE_HELD			=3'b010,
        MULTI_HELD			=3'b011,
        RELEASE_DEBOUNCE	=3'b100
    } state_t;

    state_t state;

    logic [15:0] candidate_matrix;
    logic [3:0]  candidate_key;

    logic [3:0] debounce_count;
    logic [4:0] pressed_count;


    // Count number of pressed keys

    always_comb begin

        pressed_count = 5'd0;

        for (int i = 0; i < 16; i = i + 1) begin
            pressed_count = pressed_count + key_matrix[i];
        end

    end

    // Decode a single pressed key

    always_comb begin

        case (key_matrix)

            16'b0000_0000_0000_0001: candidate_key = 4'h1;
            16'b0000_0000_0000_0010: candidate_key = 4'h2;
            16'b0000_0000_0000_0100: candidate_key = 4'h3;
            16'b0000_0000_0000_1000: candidate_key = 4'hA;

            16'b0000_0000_0001_0000: candidate_key = 4'h4;
            16'b0000_0000_0010_0000: candidate_key = 4'h5;
            16'b0000_0000_0100_0000: candidate_key = 4'h6;
            16'b0000_0000_1000_0000: candidate_key = 4'hB;

            16'b0000_0001_0000_0000: candidate_key = 4'h7;
            16'b0000_0010_0000_0000: candidate_key = 4'h8;
            16'b0000_0100_0000_0000: candidate_key = 4'h9;
            16'b0000_1000_0000_0000: candidate_key = 4'hC;

            16'b0001_0000_0000_0000: candidate_key = 4'hE;
            16'b0010_0000_0000_0000: candidate_key = 4'h0;
            16'b0100_0000_0000_0000: candidate_key = 4'hF;
            16'b1000_0000_0000_0000: candidate_key = 4'hD;

            default: candidate_key = 4'h0;

        endcase

    end

    // FSM

    always_ff @(posedge clk) begin

        if (~reset) begin

            state            <= WAITING;
            candidate_matrix <= 16'b0;
            debounce_count   <= 4'd0;

            key       <= 4'h0;
            key_valid <= 1'b0;

        end

        else begin

            // key_valid is a one-clock pulse
            key_valid <= 1'b0;

            // Only evaluate the keypad once the complete
            // four-row scan has finished.
            if (scan_complete) begin

                case (state)


                    // No key is currently being tracked

                    WAITING: begin

                        if (pressed_count == 5'd1) begin

                            candidate_matrix <= key_matrix;
                            debounce_count   <= 4'd1;

                            state <= DEBOUNCING;

                        end

                        else if (pressed_count > 5'd1) begin

                            // Multiple keys pressed at once.
                            // Do not register anything.

                            state <= MULTI_HELD;

                        end

                    end

                    // Debounce a single key

                    DEBOUNCING: begin

                        if (
                            pressed_count == 5'd1 &&
                            key_matrix == candidate_matrix
                        ) begin

                            if (debounce_count == 4'd2) begin

                                // Valid key press.
                                key       <= candidate_key;
                                key_valid <= 1'b1;

                                state <= SINGLE_HELD;

                                debounce_count <= 4'd0;

                            end

                            else begin

                                debounce_count <=
                                    debounce_count + 1'b1;

                            end

                        end

                        else if (pressed_count > 5'd1) begin

                            // Multiple keys appeared.
                            state <= MULTI_HELD;

                            debounce_count <= 4'd0;

                        end

                        else if (pressed_count == 5'd1) begin

                            // Different single key appeared.
                            candidate_matrix <= key_matrix;
                            debounce_count   <= 4'd1;

                        end

                        else begin

                            // Key disappeared before debounce completed.
                            state <= WAITING;

                            debounce_count <= 4'd0;

                        end

                    end


                    // One key has already been registered

                    SINGLE_HELD: begin

                        if (pressed_count == 5'd0) begin

                            debounce_count <= 4'd1;
                            state <= RELEASE_DEBOUNCE;

                        end

                        else if (pressed_count > 5'd1) begin

                            // Additional key(s) pressed while original key remains held.

                            state <= MULTI_HELD;

                        end
						else if (pressed_count == 5'd1 && (key_matrix != candidate_matrix)) begin
							candidate_matrix <= key_matrix; 
							debounce_count <= 4'd1;
							state <= DEBOUNCING;
						end

                    end

                    // Multiple keys are being held

                    MULTI_HELD: begin

                        if (pressed_count == 5'd1) begin

                            // Exactly one key remains.
                            // Treat it as a new key press after
                            // debouncing.

                            candidate_matrix <= key_matrix;
                            debounce_count   <= 4'd1;

                            state <= DEBOUNCING;

                        end

                        else if (pressed_count == 5'd0) begin

                            // All keys released.

                            state <= WAITING;

                        end

                    end

                    // Debounce a release

                    RELEASE_DEBOUNCE: begin

                        if (pressed_count == 5'd0) begin

                            if (debounce_count == 4'd2) begin

                                state <= WAITING;
                                debounce_count <= 4'd0;

                            end

                            else begin

                                debounce_count <=
                                    debounce_count + 1'b1;

                            end

                        end

						else if (pressed_count == 5'd1) begin
							candidate_matrix <= key_matrix;
							debounce_count <= 4'd1;
							state <= DEBOUNCING;
						end

                        else begin

                            // Multiple keys came back.
                            state <= MULTI_HELD;

                            debounce_count <= 4'd0;

                        end

                    end


                    default: begin

                        state <= WAITING;

                    end

                endcase

            end

        end

    end

endmodule
