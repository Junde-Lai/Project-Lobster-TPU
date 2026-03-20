`timescale 1ns / 1ps

module tpu_core_ai_tb;
    parameter DATA_W = 8;
    parameter ACC_W = 32;

    reg clk;
    reg rst_n;
    reg [DATA_W*4-1:0] act_in;
    reg [DATA_W*16-1:0] weights_flat;
    reg [ACC_W*4-1:0] sum_in;
    wire [ACC_W*4-1:0] post_relu_out;

    // 實例化你親手設計的 TPU 核心
    tpu_core #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .act_in(act_in),
        .weights(weights_flat), // <--- 關鍵！這裡要改成 .weights 才能連到你的 tpu_core.v
        .sum_in(sum_in),
        .post_relu_out(post_relu_out)
    );

    // 建立記憶體陣列來存放 Python 產出的資料
    reg [DATA_W-1:0] mem_weights [0:15];
    reg [DATA_W-1:0] mem_image   [0:15];

    always #5 clk = ~clk;

    integer i;
    initial begin
        $dumpfile("tpu_real_practice.vcd");
        $dumpvars(0, tpu_core_ai_tb);

        // 1. 從物理檔案載入 AI 數據 (對應 Python 生成的檔案)
        $readmemh("ai_weights_int8.hex", mem_weights);
        $readmemh("real_image_1_int8.hex", mem_image);
        
        clk = 0; rst_n = 0;
        act_in = 0; sum_in = 0;

        // 2. 將 4x4 Weights 打平成 128-bit 向量餵給晶片
        for (i=0; i<16; i=i+1) begin
            weights_flat[i*DATA_W +: DATA_W] = mem_weights[i];
        end

        #15 rst_n = 1;

        // ==========================================
        // 3. 核心大考驗：依照「脈動時序」餵真實圖片
        // 每一列資料需要遞延 1 拍 (階梯狀輸入)
        // ==========================================
        #10;
        // T=1: 餵圖片第一列的第一個元素 A00 (A03=0, A02=0, A01=0, A00=mem[0])
        act_in = {8'h00, 8'h00, 8'h00, mem_image[0]}; #10;
        
        // T=2: A01, A10
        act_in = {8'h00, 8'h00, mem_image[4], mem_image[1]}; #10;
        
        // T=3: A02, A11, A20
        act_in = {8'h00, mem_image[8], mem_image[5], mem_image[2]}; #10;
        
        // T=4: T=4拍時，所有資料就像波浪一樣全部湧入陣列 (A03, A12, A21, A30)
        act_in = {mem_image[12], mem_image[9], mem_image[6], mem_image[3]}; #10;
        
        // T=5: A13, A22, A31
        act_in = {mem_image[13], mem_image[10], mem_image[7], 8'h00}; #10;
        
        // T=6: A23, A32
        act_in = {mem_image[14], mem_image[11], 8'h00, 8'h00}; #10;
        
        // T=7: A33 (最後一個元素)
        act_in = {mem_image[15], 8'h00, 8'h00, 8'h00}; #10;
        
        // T=8: 清空輸入
        act_in = 0; #100;

        $finish;
    end
endmodule