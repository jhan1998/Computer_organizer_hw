module traffic_light (clk,rst,pass,R,G,Y);

//write your code here
input  clk;
input  rst;
input  pass;
output R;
output G;
output Y;
reg [11:0]count = 0;
reg R,G,Y;

always @( posedge clk ) begin
	if( rst == 1 ) begin
		count = 0;
	end
	else begin
	end
	if (count >= 0 && count < 1024) begin
		R = 0;
		G = 1;
		Y = 0;
	end
	else if (count >= 1024 && count < 1152) begin
		R = 0;
		G = 0;
		Y = 0;
	end
	else if (count >= 1152 && count < 1280) begin
		R = 0;
		G = 1;
		Y = 0;
	end
	else if (count >= 1280 && count < 1408) begin
		R = 0;
		G = 0;
		Y = 0;
	end
	else if (count >= 1408 && count < 1536) begin
		R = 0;
		G = 1;
		Y = 0;
	end
	else if (count >= 1536 && count < 2048) begin
		R = 0;
		G = 0;
		Y = 1;
	end
	else if (count >= 2048 && count < 3072) begin
		R = 1;
		G = 0;
		Y = 0;
	end
	else if (count > 3071) begin
		count = 0;
		R = 0;
		G = 1;
		Y = 0;
	end
	else begin
	end
	if(pass == 1 && count > 1023 && count < 3072) begin
		R = 0;
		G = 1;
		Y = 0;
		count = 0;
	end
	else begin
	end
	count = count + 1;
end

endmodule
