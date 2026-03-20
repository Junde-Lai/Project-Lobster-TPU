module tpu_core #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [(4*DATA_W)-1:0] act_in,
    input  wire [(4*ACC_W)-1:0]  sum_in,
    input  wire [(16*DATA_W)-1:0] weights,
    output wire [(4*ACC_W)-1:0]  post_relu_out
);

    wire [(4*ACC_W)-1:0] raw_sum_out;

    // 1. 呼叫我們剛才做好的 4x4 陣列
    systolic_array_4x4 array_inst (
        .clk(clk), .rst_n(rst_n),
        .act_in_flat(act_in),
        .sum_in_flat(sum_in),
        .weights_flat(weights),
        .result_out_flat(raw_sum_out)
    );

    // 2. 在底部出口接上 4 個 ReLU 門哨
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : relu_gen
            relu_unit #(ACC_W) u_relu (
                .data_in(raw_sum_out[i*ACC_W +: ACC_W]),
                .data_out(post_relu_out[i*ACC_W +: ACC_W])
            );
        end
    endgenerate

endmodule