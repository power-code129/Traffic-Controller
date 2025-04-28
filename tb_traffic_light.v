`timescale 1ns / 1ps

module tb_traffic_light;

    reg clk, rst;
    reg sensor_NS, sensor_EW;
    reg ped_NS, ped_EW;
    reg night_mode;

    wire [2:0] light_NS, light_EW;
    wire ped_signal_NS, ped_signal_EW;

    traffic_light_controller uut (
        .clk(clk),
        .rst(rst),
        .sensor_NS(sensor_NS),
        .sensor_EW(sensor_EW),
        .ped_NS(ped_NS),
        .ped_EW(ped_EW),
        .night_mode(night_mode),
        .light_NS(light_NS),
        .light_EW(light_EW),
        .ped_signal_NS(ped_signal_NS),
        .ped_signal_EW(ped_signal_EW)
    );

    // Clock generator
    always #5 clk = ~clk;  // 100MHz clock

    initial begin
        $dumpfile("traffic_wave.vcd");
        $dumpvars(0, tb_traffic_light);

        clk = 0; rst = 1;
        sensor_NS = 0; sensor_EW = 0;
        ped_NS = 0; ped_EW = 0;
        night_mode = 0;

        #20 rst = 0;

        // Simulate normal day operation
        #50 sensor_EW = 1;
        #100 sensor_EW = 0;

        #50 ped_NS = 1;
        #100 ped_NS = 0;

        #50 ped_EW = 1;
        #100 ped_EW = 0;

        // Simulate night mode
        #200 night_mode = 1;
        #1000 night_mode = 0;

        #500 $finish;
    end

endmodule
