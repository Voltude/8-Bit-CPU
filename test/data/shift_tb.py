

with open("shift_tb.txt", "w") as file:
    data_in = 0x99
    for i in range(-8, 9):
        if i < 0:
            data_out = (data_in >> -i) & 0xFF
        else:
            data_out = (data_in << i) & 0xFF
        file.write("{} {} {} {:>08b} {:>08b}\n".format(0, 0, i, data_in, data_out))