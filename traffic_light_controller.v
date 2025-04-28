module traffic_light_controller(
    input wire clk,
    input wire rst,
    input wire night_mode,
    input wire sensor_NS,
    input wire sensor_EW,
    input wire ped_NS,
    input wire ped_EW,
    output reg [2:0] light_NS,
    output reg [2:0] light_EW,
    output reg ped_signal_NS,
    output reg ped_signal_EW
);

    // State encoding
    parameter G1 = 3'd0, Y1 = 3'd1, R1 = 3'd2,
              G2 = 3'd3, Y2 = 3'd4, R2 = 3'd5,
              BLINK = 3'd6;

    reg [2:0] state, next_state;
    reg [7:0] timer;

    // Timing parameters
    parameter GREEN_TIME = 8'd100;
    parameter YELLOW_TIME = 8'd30;
    parameter RED_TIME = 8'd20;
    parameter BLINK_TIME = 8'd10;

    // Clocked state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= G1;
            timer <= 0;
        end else begin
            if (timer >= (night_mode ? BLINK_TIME :
                         (state == G1 && sensor_NS) || (state == G2 && sensor_EW) ? GREEN_TIME :
                         (state == Y1 || state == Y2) ? YELLOW_TIME : RED_TIME)) begin
                state <= next_state;
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
        end
    end

    // Combinational logic
    always @(*) begin
        // Defaults
        light_NS = 3'b001; // Red
        light_EW = 3'b001;
        ped_signal_NS = 0;
        ped_signal_EW = 0;
        next_state = state;

        case (state)
            G1: begin
                light_NS = 3'b100; // Green NS
                light_EW = 3'b001; // Red EW
                if (ped_NS) ped_signal_NS = 1;
                next_state = Y1;
            end
            Y1: begin
                light_NS = 3'b010; // Yellow NS
                light_EW = 3'b001;
                next_state = R1;
            end
            R1: begin
                light_NS = 3'b001;
                light_EW = 3'b001;
                next_state = G2;
            end
            G2: begin
                light_NS = 3'b001;
                light_EW = 3'b100; // Green EW
                if (ped_EW) ped_signal_EW = 1;
                next_state = Y2;
            end
            Y2: begin
                light_NS = 3'b001;
                light_EW = 3'b010; // Yellow EW
                next_state = R2;
            end
            R2: begin
                light_NS = 3'b001;
                light_EW = 3'b001;
                next_state = G1;
            end
            BLINK: begin
                light_NS = 3'b010; // Blinking Yellow (simulate by constant)
                light_EW = 3'b010;
                next_state = BLINK;
            end
            default: next_state = G1;
        endcase

        if (night_mode)
            next_state = BLINK;
    end

endmodule
