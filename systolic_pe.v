module systolic_pe #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32 // AI 晶片通常用 32-bit 來累加，防止爆掉
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [DATA_W-1:0] weight_in, // 固定在 PE 裡的權重
    input  wire [DATA_W-1:0] act_in,    // 從左邊傳來的特徵
    input  wire [ACC_W-1:0]  sum_in,    // 從上面傳下來的部分和
    
    output reg  [DATA_W-1:0] act_out,   // 傳給右邊的特徵
    output reg  [ACC_W-1:0]  sum_out    // 傳給下面的新部分和
);

    wire [ACC_W-1:0] product;
    assign product = act_in * weight_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_out <= 0;
            sum_out <= 0;
        end else begin
            act_out <= act_in;           // 把收到的 A 存起來，下一拍給右邊
            sum_out <= sum_in + product; // 算完的新結果，下一拍給下面
        end
    end
endmodule