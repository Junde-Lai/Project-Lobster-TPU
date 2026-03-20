import numpy as np

# 1. AI 模型端：權重 (Weights)
ai_model_weights = np.array([
    [ 10, 100,  10,  10], 
    [ 10, 100,  10,  10], 
    [ 10, 100,  10,  10], 
    [ 10, 100,  10,  10]  
], dtype=np.int8)

# 2. 真實圖片端：手寫數字 1 (Activation)
test_image_1 = np.array([
    [ 15, 110,   5,   5], 
    [ 10, 120,  20,   5], 
    [ 30, 100,   5,   5], 
    [ 10,  95,  15,  15]  
], dtype=np.int8)

# 軟體模擬 (標準答案)
# 注意：這裡使用 matmul 是為了對應硬體邏輯
software_result = np.maximum(0, np.matmul(test_image_1, ai_model_weights))

print("--- 軟體模擬結果 (請記住這些數字) ---")
print(software_result)

# 3. 修正後的 save_hex 函式：先轉成 int 再計算，避免 Overflow
def save_hex(arr, name):
    with open(name, 'w') as f:
        for x in arr.flatten():
            # 強制轉換為 Python 原生 int，徹底解決溢位問題
            val = int(x) & 0xFF
            f.write(f"{val:02x}\n")

save_hex(ai_model_weights, "ai_weights_int8.hex")
save_hex(test_image_1, "real_image_1_int8.hex")
print("\n[OK] 數據已產出：ai_weights_int8.hex, real_image_1_int8.hex")