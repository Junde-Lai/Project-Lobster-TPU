module systolic_array_4x4 #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  wire clk,
    input  wire rst_n,
    // 將 4 個 8-bit 輸入打平成一個 32-bit 向量 (4*8=32)
    input  wire [(4*DATA_W)-1:0] act_in_flat,
    // 將 4 個 32-bit 輸入打平成一個 128-bit 向量 (4*32=128)
    input  wire [(4*ACC_W)-1:0]  sum_in_flat,
    // 16 個 PE 的權重全部排成一排 (16*8=128)
    input  wire [(16*DATA_W)-1:0] weights_flat,
    
    // 輸出也打平 (4*32=128)
    output wire [(4*ACC_W)-1:0]  result_out_flat
);

    wire [DATA_W-1:0] act_conn [0:3][0:4];
    wire [ACC_W-1:0]  sum_conn [0:4][0:3];

    genvar r, c;
    generate
        // 解開打平的輸入
        for (r = 0; r < 4; r = r + 1) begin
            assign act_conn[r][0] = act_in_flat[r*DATA_W +: DATA_W];
            assign sum_conn[0][r] = sum_in_flat[r*ACC_W +: ACC_W];
        end

        // 建立 PE 陣列
        for (r = 0; r < 4; r = r + 1) begin : row
            for (c = 0; c < 4; c = c + 1) begin : col
                systolic_pe #(DATA_W, ACC_W) pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .weight_in(weights_flat[(r*4+c)*DATA_W +: DATA_W]),
                    .act_in(act_conn[r][c]),
                    .sum_in(sum_conn[r][c]),
                    .act_out(act_conn[r][c+1]),
                    .sum_out(sum_conn[r+1][c])
                );
            end
        end

        // 打平輸出結果
        for (c = 0; c < 4; c = c + 1) begin
            assign result_out_flat[c*ACC_W +: ACC_W] = sum_conn[4][c];
        end
    endgenerate

endmodule