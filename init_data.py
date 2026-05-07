#!/usr/bin/env python
"""
创建超级用户和示例商品数据的脚本
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'djecommerce.settings.development')
django.setup()

from django.contrib.auth.models import User
from core.models import Item

def create_superuser():
    """创建超级用户"""
    username = 'admin'
    email = 'admin@example.com'
    password = 'admin123456'
    
    if not User.objects.filter(username=username).exists():
        User.objects.create_superuser(username, email, password)
        print(f'✅ 超级用户创建成功！')
        print(f'   用户名: {username}')
        print(f'   邮箱: {email}')
        print(f'   密码: {password}')
    else:
        print(f'⚠️  超级用户 "{username}" 已存在')

def create_sample_items():
    """创建示例商品"""
    items_data = [
        {
            'title': '经典白色T恤',
            'price': 99.00,
            'discount_price': 79.00,
            'category': 'S',
            'label': 'P',
            'slug': 'classic-white-tshirt',
            'description': '高品质纯棉T恤，舒适透气，适合日常穿着。'
        },
        {
            'title': '运动跑步鞋',
            'price': 399.00,
            'discount_price': None,
            'category': 'SW',
            'label': 'S',
            'slug': 'sports-running-shoes',
            'description': '专业跑步鞋，减震耐磨，适合长跑和日常训练。'
        },
        {
            'title': '时尚牛仔外套',
            'price': 599.00,
            'discount_price': 499.00,
            'category': 'OW',
            'label': 'D',
            'slug': 'fashion-denim-jacket',
            'description': '经典牛仔外套，百搭时尚，适合春秋季节。'
        },
        {
            'title': '运动休闲裤',
            'price': 199.00,
            'discount_price': None,
            'category': 'SW',
            'label': 'P',
            'slug': 'sports-casual-pants',
            'description': '舒适运动裤，弹性面料，适合运动和休闲。'
        },
        {
            'title': '纯棉格子衬衫',
            'price': 159.00,
            'discount_price': 129.00,
            'category': 'S',
            'label': 'S',
            'slug': 'cotton-plaid-shirt',
            'description': '经典格子衬衫，纯棉材质，舒适透气。'
        },
        {
            'title': '防风冲锋衣',
            'price': 799.00,
            'discount_price': 699.00,
            'category': 'OW',
            'label': 'P',
            'slug': 'windproof-jacket',
            'description': '专业户外冲锋衣，防风防水，适合户外运动。'
        },
    ]
    
    created_count = 0
    for item_data in items_data:
        if not Item.objects.filter(slug=item_data['slug']).exists():
            Item.objects.create(**item_data)
            created_count += 1
            print(f'✅ 创建商品: {item_data["title"]}')
        else:
            print(f'⚠️  商品已存在: {item_data["title"]}')
    
    print(f'\n总共创建了 {created_count} 个新商品')

if __name__ == '__main__':
    print('=' * 60)
    print('开始初始化数据...')
    print('=' * 60)
    print()
    
    create_superuser()
    print()
    
    create_sample_items()
    print()
    
    print('=' * 60)
    print('数据初始化完成！')
    print('=' * 60)
    print()
    print('📱 访问地址:')
    print('   前台首页: http://localhost:8000/')
    print('   后台管理: http://localhost:8000/admin/')
    print()
    print('🔐 后台登录信息:')
    print('   用户名: admin')
    print('   密码: admin123456')
    print()
