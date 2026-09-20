`timescale 1ns / 1ps

module TB_chip_top;

reg clk, rst, seed_reg_en, triv_rst, triv_en;
reg [3:0] data_in;
reg [3:0] state = 3'b000;

wire clk_PAD, rst_PAD, seed_reg_en_PAD, triv_rst_PAD, triv_en_PAD;
wire [63:0] stream_out;
wire [287:0] seed;
wire notclk;

parameter clk_period = 10;
integer counter;

// Unit Under Test
chip_top UUT (.clk_PAD(clk_PAD), .rst_PAD(rst_PAD), .seed_reg_en_PAD(seed_reg_en_PAD), .triv_rst_PAD(triv_rst_PAD), .triv_en_PAD(triv_en_PAD), .data_in_PAD(data_in_PAD), .data_out_PAD(stream_out));

assign notclk = ~clk;
assign clk_PAD = notclk;
assign rst_PAD = rst;
assign seed_reg_en_PAD = seed_reg_en;
assign triv_rst_PAD = triv_rst;
assign triv_en_PAD = triv_en;
assign data_in_PAD = data_in;
assign seed = 288'hd099059daa1b3475fe218a1f1148a1934e9b40faf363b5221028b68e40aa611e2de0726b;

// Clock Process
always begin
    clk <= 0;
    #(clk_period/2);
    clk <= 1;
    #(clk_period/2);
end

// Stimulation Process
always @(posedge clk) begin
    case(state)
        3'b000:
            begin
                rst                         = 1'b1;
                seed_reg_en                 = 1'b0;
                triv_rst                    = 1'b0;
                triv_en                     = 1'b0;
                data_in                     = 4'b0000;
                counter                     = 0;
                state                       = 3'b001;
            end
        3'b001:
            begin
                rst                         = 1'b0;
                seed_reg_en                 = 1'b1;
                data_in                     <= seed[284-4*counter +: 4];
                counter                     = counter + 1;
                if (counter == 72) begin
                    counter                 = 0;
                    state                   = 3'b010;
                end
            end
        3'b010:
            begin
                seed_reg_en                 = 1'b0;
                triv_rst                    = 1'b1;
                data_in                     = 4'b0000;
                state                       = 3'b011;
            end
        3'b011:
            begin
                triv_rst                    = 1'b0;
                triv_en                     = 1'b1;
                counter                     = counter + 1;
                if (counter == 200) begin
                    counter                 = 0;
                    state                   = 3'b100;
                end
            end
        3'b100:
            begin
                triv_en                     = 1'b0;
                if (stream_out == 64'hf0b8a660df1538f7) begin
                    $display("SUCCESS");
                end else begin
                    $display("FAILURE");
                end
                state                       = 3'b101;
            end
        3'b101:
            begin
                rst                         = 1'b1;
                $finish;
            end
    endcase
end

endmodule