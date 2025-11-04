library IEEE;
use IEEE.std_logic_1164.all;

Entity FA is
    port(
        a, b, c_in: in std_logic;
        s, c_out: out std_logic
    );
end FA;

Architecture Behavioral of FA is
begin
    s <= a xor b xor c_in;
    c_out <= ((a xor b) and c_in) or (a and b);
end Behavioral;