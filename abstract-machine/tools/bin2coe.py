#!/usr/bin/env python3
import sys
import os.path  # 导入路径处理模块

def bin2coe(bin_file, coe_file, width=32, depth=None):
    # 读取BIN文件（二进制模式）
    with open(bin_file, 'rb') as f:
        bin_data = f.read()
    
    # 按width位（32位=4字节）拆分，不足补零
    words = []
    for i in range(0, len(bin_data), 4):
        # 取4字节，不足补0
        word_bytes = bin_data[i:i+4] + b'\x00'*(4 - len(bin_data[i:i+4]))
        # 转为大端/小端（根据你的CPU架构！RISCV/ARM一般是小端）
        word = int.from_bytes(word_bytes, byteorder='little')  # 小端（常用）
        # word = int.from_bytes(word_bytes, byteorder='big')   # 大端（极少用）
        words.append(f"{word:08X}")  # 转为8位16进制字符串
    
    # 若指定depth，补零到指定深度
    if depth and len(words) < depth:
        words += ['00000000'] * (depth - len(words))
    
    # 写入COE文件
    with open(coe_file, 'w') as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        f.write(',\n'.join(words) + ';\n')

if __name__ == '__main__':
    # 检查输入参数数量（至少1个：BIN文件路径）
    if len(sys.argv) < 2:
        print("用法1: python bin2coe.py 输入.bin                # 自动生成 输入.coe")
        print("用法2: python bin2coe.py 输入.bin 目标深度       # 自动生成 输入.coe，并补零到指定深度")
        print("示例1: python bin2coe.py firmware.bin")
        print("示例2: python bin2coe.py firmware.bin 1024")
        sys.exit(1)
    
    # 提取输入的BIN文件路径
    bin_file = sys.argv[1]
    # 自动生成COE文件名：替换BIN后缀为COE（保留原路径）
    # 比如：./test/firmware.bin → ./test/firmware.coe
    coe_file = os.path.splitext(bin_file)[0] + '.coe'
    
    # 处理可选的深度参数
    depth = int(sys.argv[2]) if len(sys.argv)>=3 else None
    
    # 执行转换
    bin2coe(bin_file, coe_file, depth=depth)
    print(f"转换完成！已生成COE文件：{coe_file}")