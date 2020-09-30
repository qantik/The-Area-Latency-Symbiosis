def rotate_left(x):
    return x[1:] + [x[0]]

def swap(x, i, j):
    tmp = x[i]
    x[i] = x[j]
    x[j] = tmp
    return x

x = [i for i in range(16)]
# x = [
#     'x15', '15', 'x14', '14', 'x13', '13', 'x12', '12',
#     'x11', '11', 'x10', '10', 'x09', '09', 'x08', '08',
#     'x07', '07', 'x06', '06', 'x05', '05', 'x04', '04',
#     'x03', '03', 'x02', '02', 'x01', '01', 'x00', '00'
# ]

# x = ['10', '53', '13', '51', '11', '52', '12', '50']
x = [
    '5F', '1F', '7F', '3F', '5E', '1E', '7E', '3E', '5D', '1D', '7D', '3D', '5C', '1C', '7C', '3C',
    '5B', '1B', '7B', '3B', '5A', '1A', '7A', '3A', '59', '19', '79', '39', '58', '18', '78', '38',
    '57', '17', '77', '37', '56', '16', '76', '36', '55', '15', '75', '35', '54', '14', '74', '34',
    '53', '13', '73', '33', '52', '12', '72', '32', '51', '11', '71', '31', '50', '10', '70', '30',
    '4F', '0F', '6F', '2F', '4E', '0E', '6E', '2E', '4D', '0D', '6D', '2D', '4C', '0C', '6C', '2C',
    '4B', '0B', '6B', '2B', '4A', '0A', '6A', '2A', '49', '09', '69', '29', '48', '08', '68', '28',
    '47', '07', '67', '27', '46', '06', '66', '26', '45', '05', '65', '25', '44', '04', '64', '24',
    '43', '03', '63', '23', '42', '02', '62', '22', '41', '01', '61', '21', '40', '00', '60', '20'
]

x = [x[-1]] + x[:127] # rotate one to the right
print("ORIGINAL")
print(x)

for r in range(4):
    print("round", r)
    print(x)
    for i in range(128):
        
        if r % 4 == 0:
            # reversal (part 2)
            if i == 0:
                x = swap(x, 0, 127)

            # k1 << 2 
            if i >= 11 and i <= 63 and i % 4 == 3:
                x = swap(x, 119, 127)
             
            # k7 <<< 8
            if i >= 3 and i <= 31 and i % 4 == 3:
                x = swap(x, 0, 32)
            # k7 << 4
            if i >= 20 and i <= 64 and i % 4 == 0:
                x = swap(x, 111, 127)
            # k6 << 4 (part 1)
            if i >= 84 and i <= 128 and i % 4 == 0:
                x = swap(x, 111, 127)

        elif r % 4 == 1:
             # k6 << 4 (part 2)
             if i == 0:
                 x = swap(x, 111, 127)
             
             # k3 << 2
             if i >= 13 and i <= 65 and i % 4 == 1:
                 x = swap(x, 119, 127)

             # k1 <<< 8
             if i >= 2 and i <= 30 and i % 4 == 2:
                 x = swap(x, 0, 32)
             # k1 << 4
             if i >= 19 and i <= 63 and i % 4 == 3:
                 x = swap(x, 111, 127)
             # k0 << 4
             if i >= 83 and i <= 127 and i % 4 == 3:
                 x = swap(x, 111, 127)

        if r % 4 == 2:
            # reversals
            if i % 4 == 0:
                x = swap(x, 1, 2)
            if i % 4 == 2:
                x = swap(x, 0, 127)
            
            # k5 << 2
            if i >= 10 and i <= 62 and i % 4 == 2:
                x = swap(x, 119, 127)
        
            # k3 << 8
            if i >= 4 and i <= 32 and i % 4 == 0:
                x = swap(x, 0, 32)
            # k3 << 4
            if i >= 21 and i <= 65 and i % 4 == 1:
                x = swap(x, 111, 127)
            # k2 << 4 (part 1)
            if i >= 85 and i <= 128 and i % 4 == 1:
                x = swap(x, 111, 127)
        
        if r % 4 == 3:
            # reversals (part 1)
            if i % 4 == 0: 
                x = swap(x, 3, 4)
            if i % 4 == 0 and i > 0:
                x = swap(x, 0, 127)
            
            # k2 << 4 (part 2)
            if i == 1:
                x = swap(x, 111, 127)
            
            # k7 << 2 
            if i >= 12 and i <= 64 and i % 4 == 0:
                x = swap(x, 119, 127)
            
            # k5 << 8
            if i >= 1 and i <= 29 and i % 4 == 1:
                x = swap(x, 0, 32)
            # k5 << 4
            if i >= 18 and i <= 62 and i % 4 == 2:
                x = swap(x, 111, 127)
            # k4 << 4
            if i >= 82 and i <= 128 and i % 4 == 2:
                x = swap(x, 111, 127)

        x = rotate_left(x)

print(x)

# for i in range(128):
#     # if i < 12:
#     #     x = swap(x, 0, 4)
#     # if i >= 16 and i < 28:
#     #     x = swap(x, 112, 116)
#     # if i >= 32 and i < 44:
#     #     x = swap(x, 96, 100)
#     # if i >= 48 and i < 62:
#     #     x = swap(x, 80, 82)
#     if i > 0 and i <= 127:
#         x = swap(x, 126, 127)
#     x = rotate_left(x)


# y = [i for i in range(4)]

# for i in range(4):
#     if i >= 0 and i <= 2:
#         y = swap(y, 2, 3)
#     y = rotate_left(y)

