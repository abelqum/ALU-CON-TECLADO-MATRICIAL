library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display is
    Port (
        Datos: in std_logic_vector(15 downto 0);
        clk_27mhz : in  STD_LOGIC;
        -- --- PUERTO NUEVO ---
        signo : in STD_LOGIC; -- '1' si es negativo
        seg       : out STD_LOGIC_VECTOR(0 to 7);
        an        : out STD_LOGIC_VECTOR(3 downto 0)
    );
end display;

architecture Behavioral of display is
 
    signal contador : integer := 0;
    signal clk_10khz : STD_LOGIC := '0';
    signal display_sel : INTEGER := 0;
    signal bcd_actual : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    signal unidades, decenas, centenas, millares: std_logic_vector(3 downto 0);
begin

    unidades <= Datos(3 downto 0);
    decenas  <= Datos(7 downto 4);
    centenas <= Datos(11 downto 8);
    millares <= Datos(15 downto 12);

    process(clk_27mhz)
    begin
        if rising_edge(clk_27mhz) then
            if contador = 1349 then
                contador <= 0;
                clk_10khz <= not clk_10khz;
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;

    process(clk_10khz)
    begin
        if rising_edge(clk_10khz) then
            display_sel <= (display_sel + 1) mod 4;
        end if;
    end process;

    -- --- PROCESO MODIFICADO ---
    process(display_sel, unidades, decenas, centenas, millares, signo)
    begin
        case display_sel is
            when 0 =>
                bcd_actual <= unidades;
                an <= "1110";
            when 1 =>
                bcd_actual <= decenas;
                an <= "1101";
            when 2 =>
                bcd_actual <= centenas;
                an <= "1011";
            when 3 =>
                if signo = '1' then
                    bcd_actual <= "1111"; -- Código especial para "guion"
                else
                    bcd_actual <= millares;
                end if;
                an <= "0111";
            when others =>
                bcd_actual <= "0000";
                an <= "1111";
        end case;
    end process;

    -- --- PROCESO MODIFICADO ---
    process(bcd_actual)
    begin
        case bcd_actual is
            when "0000" => seg <= "11111100"; -- 0
            when "0001" => seg <= "01100000"; -- 1
            when "0010" => seg <= "11011010"; -- 2
            when "0011" => seg <= "11110010"; -- 3
            when "0100" => seg <= "01100110"; -- 4
            when "0101" => seg <= "10110110"; -- 5
            when "0110" => seg <= "10111110"; -- 6
            when "0111" => seg <= "11100000"; -- 7
            when "1000" => seg <= "11111110"; -- 8
            when "1001" => seg <= "11110110"; -- 9
            when "1111" => seg <= "00000010"; -- Guion "-" (segmento g)
            when others => seg <= "00000000"; 
        end case;
    end process;

end Behavioral;
