// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output reg        instr_read,
    output reg        data_read,
    output reg [31:0] instr_addr,
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);

/* Add your design */
reg [31:0] rs [31:0];
reg [31:0] pc;
reg [6:0] op_code, fun7, b_imm1, s_imm1;
reg [4:0] rs1, rs2, rd, b_imm2, s_imm2;
reg [2:0] fun3;
reg [11:0] i_imm;
reg [19:0] u_imm;
reg [1:0] mode;
reg half, byte, u_half, u_byte, full;
reg [31:0] temp;
integer i;

initial begin
    instr_read <= 1'd0;
    instr_addr <= 32'd0;
    data_read <= 1'd0;
    data_addr <= 32'd0;
    temp = 32'd0;
    data_write <= 4'd0;
    for(i = 0; i < 32; i=i+1)begin
        rs[i] <= 32'd0;
    end
    pc <= 32'd0;
    mode <= 2'd0;
    half <= 1'd0;
    byte <= 1'd0;
    u_half <= 1'd0;
    u_byte <= 1'd0;
    full <= 1'd0;
end

always @ (posedge clk or posedge rst)
begin
    case(mode)
        2'd0:begin
 	     if(data_read != 1'd0)begin
	        if(full)begin
                    full <= 1'd0;
                    rs[rd] <= data_out;
                    data_read <= 1'd0;
                end
            else if(byte)begin
                    byte <= 1'd0;
                    rs[rd] <= data_out[7:0];
                    rs[rd][31:8] <= {24{data_out[7]}};
                    data_read <= 1'd0;
                end
            else if(half)begin
                    half <= 1'd0;
                    rs[rd] <=  data_out[15:0];
                    rs[rd][31:16] <= {16{data_out[15]}};
                    data_read <= 1'd0;
                end
            else if(u_byte)begin
                    u_byte <= 1'd0;
                    rs[rd][7:0] <= data_out[7:0];
                    rs[rd][31:8] <= 24'd0;
                    data_read <= 1'd0;
                end
            else if(u_half)begin
                    u_half <= 1'd0;
                    rs[rd] <= data_out[15:0];
                    rs[rd][31:16] <= 16'd0;
                    data_read <= 1'd0;
                end
            end
            rs[0] <= 32'd0;
            instr_read <= 1'd1;
            mode <= 2'd1;
        end

        2'd1:begin
            pc <= pc + 32'd4;
            op_code <= instr_out[6:0];
            case(instr_out[6:0])
                7'b0110011:begin
                    fun7 <= instr_out[31:25];
                    rs2 <= instr_out[24:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    rd <= instr_out[11:7];
                end
                7'b0010011:begin
                    i_imm <= instr_out[31:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    rd <= instr_out[11:7];
                end
                7'b1100111:begin
                    i_imm <= instr_out[31:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    rd <= instr_out[11:7];
                end
                7'b0000011:begin //lw
                    i_imm <= instr_out[31:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    rd <= instr_out[11:7];
                end
                7'b0100011:begin //sw
                    s_imm1 <= instr_out[31:25];
                    rs2 <= instr_out[24:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    s_imm2 <= instr_out[11:7];
                end
                7'b1100011:begin
                    b_imm1 <= instr_out[31:25];
                    rs2 <= instr_out[24:20];
                    rs1 <= instr_out[19:15];
                    fun3 <= instr_out[14:12];
                    b_imm2 <= instr_out[11:7];
                end
                7'b0010111:begin
                    u_imm <= instr_out[31:12];
                    rd <= instr_out[11:7];
                end
                7'b0110111:begin
                    u_imm <= instr_out[31:12];
                    rd <= instr_out[11:7];
                end
                7'b1101111:begin
                    u_imm <= instr_out[31:12];
                    rd <= instr_out[11:7];
                end
            endcase
            mode <= 2'd2;
        end

        2'd2:begin
            case(instr_out[6:0])
                7'b0110011:begin
                    case(fun3)
                        3'b000:begin
                            if(fun7 == 7'b0000000)begin
                                rs[rd] <= $signed(rs[rs1]) + $signed(rs[rs2]);
                        end
                            else if(fun7 == 7'b0100000)begin
                                rs[rd] <= $signed(rs[rs1]) - $signed(rs[rs2]);
                            end
                            else begin
                            end
                        end
                        3'b001:begin
                            rs[rd] <= rs[rs1] << rs[rs2][4:0];
                        end
                        3'b010:begin
                            rs[rd] <= $signed({{27{rs[rs1][4]}},rs[rs1]}) < $signed({{27{rs[rs2][4]}},rs[rs2]}) ? 32'd1 : 32'd0;
                        end
                        3'b011:begin
                            rs[rd] <= rs[rs1] < rs[rs2] ? 32'd1 : 32'd0;
                        end
                        3'b100:begin
                            rs[rd] <= rs[rs1] ^ rs[rs2];
                        end
                        3'b101:begin
                            if(fun7 == 7'b0000000)begin
                                rs[rd] <= rs[rs1] >> rs[rs2][4:0];
                            end
                            else if(fun7 == 7'b0100000)begin
                                rs[rd] <= $signed(rs[rs1]) >>> rs[rs2][4:0];
                            end
                            else begin
                            end
                        end
                        3'b110:begin
                            rs[rd] <= rs[rs1] | rs[rs2];
                        end
                        3'b111:begin
                            rs[rd] <= rs[rs1] & rs[rs2];
                        end
                    endcase
                end
                7'b0010011:begin
                    case(fun3)
                        3'b000:begin
                            rs[rd] <= $signed(rs[rs1]) + $signed({{20{i_imm[11]}},i_imm});
                        end
                        3'b010:begin
                            rs[rd] <= $signed(rs[rs1]) < $signed({{20{i_imm[11]}},i_imm}) ? 32'd1 : 32'd0;
                        end
                        3'b011:begin
                            rs[rd] <= rs[rs1] < {{20{i_imm[11]}},i_imm} ? 32'd1 : 32'd0;
                        end
                        3'b100:begin
                            rs[rd] <= rs[rs1] ^ {{20{i_imm[11]}},i_imm};
                        end
                        3'b110:begin
                            rs[rd] <= rs[rs1] | {{20{i_imm[11]}},i_imm};
                        end
                        3'b111:begin
                            rs[rd] <= rs[rs1] & {{20{i_imm[11]}},i_imm};
                        end
                        3'b001:begin
                            rs[rd] <= rs[rs1] << i_imm[4:0];
                        end
                        3'b101:begin
                            if(i_imm[11:5] == 7'b0000000)begin
                                rs[rd] <= rs[rs1] >> i_imm[4:0];
                            end
                            else if(i_imm[11:5] == 7'b0100000)begin
                                rs[rd] <= $signed(rs[rs1]) >>> i_imm[4:0];
                            end
                            else begin
                            end
                        end
                    endcase
                end
                7'b0000011:begin //lw
                    case(fun3)
                        3'b010:begin
                            data_read <= 1'd1;
                            data_addr <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm[11:0]});
                            full <= 1'd1;
                        end
                        3'b000:begin
                            data_read <= 1'd1;
                            data_addr <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm[11:0]});
                            byte <= 1'd1;
                        end
                        3'b001:begin
                            data_read <= 1'd1;
                            data_addr <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm[11:0]});
                            half <= 1'd1;
                        end
                        3'b100:begin
                            data_read <= 1'd1;
                            data_addr <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm[11:0]});
                            u_byte <= 1'd1;
                        end
                        3'b101:begin
                            data_read <= 1'd1;
                            data_addr <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm[11:0]});
                            u_half <= 1'd1;
                        end
                    endcase
                end
                7'b1100111:begin
                    rs[rd] <= pc;
                    pc <= rs[rs1] + $signed({{20{i_imm[11]}},i_imm});
                    pc[0] <= 0;
                end
                7'b0100011:begin //sw
                    case(fun3)
                        3'b010:begin
                            data_write <= 4'b1111;
                            data_addr <= rs[rs1] + {{20{s_imm1[6]}},s_imm1,s_imm2};
                            data_in <= rs[rs2];
                        end
                        3'b000:begin
                            data_addr <= rs[rs1] + {{20{s_imm1[6]}},s_imm1,s_imm2};
                            temp = 32'd0 - {{20{s_imm1[6]}},s_imm1,s_imm2};
                            if(temp[1:0] == 2'd1) begin
                                data_write = 4'b1000;
                                data_in[31:24] <= rs[rs2][7:0];
                            end
                            else if(temp[1:0] == 2'd2) begin
                                data_write = 4'b0100;
                                data_in[23:16] <= rs[rs2][7:0];
                            end
                            else if(temp[1:0] == 2'd3) begin
                                data_write = 4'b0010;
                                data_in[15:8] <= rs[rs2][7:0];
                            end
                            else if(temp[1:0] == 2'd0) begin
                                data_write = 4'b0001;
                                data_in[7:0] <= rs[rs2][7:0];
                            end
                        end
                        3'b001:begin
                            data_addr <= rs[rs1] + {{20{s_imm1[6]}},s_imm1,s_imm2};
                            temp = 32'd0 - {{20{s_imm1[6]}},s_imm1,s_imm2};
                            if(temp[1:0] == 2'd2) begin
                                data_write = 4'b1100;
                                data_in[31:16] <= rs[rs2][15:0];
                            end
                            else if(temp[1:0] == 2'd3) begin
                                data_write = 4'b0110;
                                data_in[27:12] <= rs[rs2][15:0];
                            end
                            else if(temp[1:0] == 2'd0) begin
                                data_write = 4'b0011;
                                data_in[15:0] <= rs[rs2][15:0];
                            end
                        end
                    endcase
                end
                7'b1100011:begin
                    case(fun3)
                        3'b000:begin
                            pc <= (rs[rs1] == rs[rs2]) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                        3'b001:begin
                            pc <= (rs[rs1] != rs[rs2]) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                        3'b100:begin
                            pc <= ($signed(rs[rs1]) < $signed(rs[rs2])) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                        3'b101:begin
                            pc <= ($signed(rs[rs1]) >= $signed(rs[rs2])) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                        3'b110:begin
                            pc <= (rs[rs1] < rs[rs2]) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                        3'b111:begin
                            pc <= (rs[rs1] >= rs[rs2]) ? pc + $signed({{19{b_imm1[6]}},b_imm1[6],b_imm2[0],b_imm1[5:0],b_imm2[4:1],1'd0}) -32'd4:pc;
                        end
                    endcase
                end
                7'b0010111:begin
                    rs[rd] <= pc + $signed({u_imm,12'd0}) - 32'd4;
                end
                7'b0110111:begin
                    rs[rd] <= $signed({u_imm,12'd0});
                end
                7'b1101111:begin
                    rs[rd] <= pc;
                    pc <= pc + $signed({{11{u_imm[19]}},u_imm[19],u_imm[7:0],u_imm[8],u_imm[18:9],1'd0}) -32'd4;
                end
            endcase
            mode <= 2'd3;
        end
        2'd3:begin
            if(data_write != 4'd0)begin
                data_write <= 4'd0;
            end
            instr_addr <= pc;
            mode <= 2'd0;
        end
    endcase
end


endmodule
