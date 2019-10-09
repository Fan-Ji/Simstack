function buf = rtuwritecoil(devaddr, regH, regL, value)
buf = [devaddr, 05, regH, regL, flip(typecast(uint16(value), 'uint8'))];
buf = append_crc(buf);
end

