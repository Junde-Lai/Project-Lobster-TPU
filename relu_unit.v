module relu_unit #(
    parameter WIDTH = 32
)(
    input  wire signed [WIDTH-1:0] data_in,
    output wire [WIDTH-1:0] data_out
);
    // 檢查符號位：如果是 1 (負數)，輸出 0；否則輸出原值
    assign data_out = (data_in[WIDTH-1] == 1'b1) ? {WIDTH{1'b0}} : data_in;
endmodule