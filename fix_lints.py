import os
import glob
import re

base_dir = r"c:\2306075_Rizky Bagja N\SEMESTER 6\PRAK MOBILE\tbprakmobile_2306075\lib"

# 1. Fix use_super_parameters
def fix_super_parameters():
    for root, _, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Regex to match: const WidgetName({Key? key, ...}) : super(key: key);
                # We need a robust replacement
                new_content = re.sub(
                    r"const\s+([A-Za-z0-9_]+)\s*\(\{\s*Key\?\s+key(.*?)\}\)\s*:\s*super\(\s*key\s*:\s*key\s*\)\s*;",
                    r"const \1({super.key\2});",
                    content
                )
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed super_parameters in {filepath}")

# 2. Fix withOpacity -> withValues(alpha: ...)
def fix_with_opacity():
    for root, _, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = re.sub(
                    r"\.withOpacity\((.*?)\)",
                    r".withValues(alpha: \1)",
                    content
                )
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed withOpacity in {filepath}")

# 3. Fix prefer_final_fields
def fix_final_fields():
    order_provider = os.path.join(base_dir, "providers", "order_provider.dart")
    with open(order_provider, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("List<OrderModel> _orders = [];", "final List<OrderModel> _orders = [];")
    with open(order_provider, 'w', encoding='utf-8') as f:
        f.write(content)
        
    product_provider = os.path.join(base_dir, "providers", "product_provider.dart")
    with open(product_provider, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("List<ProductModel> _products = [];", "final List<ProductModel> _products = [];")
    with open(product_provider, 'w', encoding='utf-8') as f:
        f.write(content)

print("Starting fixes...")
fix_super_parameters()
fix_with_opacity()
fix_final_fields()
print("Done.")
