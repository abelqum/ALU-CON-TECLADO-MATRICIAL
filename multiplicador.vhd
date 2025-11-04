Library IEEE;
Use IEEE.std_logic_1164.all;

entity Multiplicador is
port(
    A, B: in std_logic_vector(5 downto 0);
    clk, reset: in std_logic;
    Resultado: out std_logic_vector(11 downto 0)
);
end Multiplicador;

architecture Behavioral of Multiplicador is

component FAS12b is
    port(
        a, b : in std_logic_vector(11 downto 0);
        s_r : in std_logic;
        s   : out std_logic_vector(11 downto 0);
        cout : out std_logic
    );
end component;

signal r0, r1, r2, r3, r4, r5, s1, s2, s3, s4, s5: std_logic_vector(11 downto 0) := (others => '0');
signal i: integer := 0;
signal cout1, cout2, cout3, cout4, cout5: std_logic;
signal A_reg, B_reg: std_logic_vector(5 downto 0) := (others => '0');
signal start_mult, mult_done: std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '0' then
        resultado <= (others => '0');
        r0 <= (others => '0');
        r1 <= (others => '0');
        r2 <= (others => '0');
        r3 <= (others => '0');
        r4 <= (others => '0');
        r5 <= (others => '0');
        i <= 0;
        A_reg <= (others => '0');
        B_reg <= (others => '0');
        start_mult <= '0';
        mult_done <= '0';
            
    elsif rising_edge(clk) then
        -- Registrar las entradas al inicio
        if i = 0 and start_mult = '0' then
            A_reg <= A;
            B_reg <= B;
            start_mult <= '1';
        end if;
        
        if start_mult = '1' and i < 6 then
            case i is
                when 0 =>
                    if B_reg(0) = '0' then
                        r0 <= (others => '0');
                    else
                        r0 <= (others => '0');
                        r0(5 downto 0) <= A_reg;
                    end if;
                when 1 =>
                    if B_reg(1) = '0' then
                        r1 <= (others => '0');
                    else
                        r1 <= (others => '0');
                        r1(6 downto 1) <= A_reg;
                    end if;
                when 2 =>
                    if B_reg(2) = '0' then
                        r2 <= (others => '0');
                    else
                        r2 <= (others => '0');
                        r2(7 downto 2) <= A_reg;
                    end if;
                when 3 =>
                    if B_reg(3) = '0' then
                        r3 <= (others => '0');
                    else
                        r3 <= (others => '0');
                        r3(8 downto 3) <= A_reg;
                    end if;
                when 4 =>
                    if B_reg(4) = '0' then
                        r4 <= (others => '0');
                    else
                        r4 <= (others => '0');
                        r4(9 downto 4) <= A_reg;
                    end if;
                when 5 =>
                    if B_reg(5) = '0' then
                        r5 <= (others => '0');
                    else
                        r5 <= (others => '0');
                        r5(10 downto 5) <= A_reg;
                    end if;
                when others =>
                    null;
            end case;
            i <= i + 1;
        elsif i = 6 then
            -- Asignar el resultado final cuando i = 6
            Resultado <= s5;
            mult_done <= '1';
            start_mult <= '0';
        end if;
        
        -- Reiniciar para nueva multiplicación
        if mult_done = '1' then
            i <= 0;
            mult_done <= '0';
            -- Mantener el resultado hasta siguiente multiplicación
        end if;
    end if;
end process;

-- Sumadores (concurrentes)
sum1: FAS12b port map(
    a => r0,
    b => r1,
    s_r => '0',
    s => s1,
    cout => cout1
);

sum2: FAS12b port map(
    a => s1,
    b => r2,
    s_r => '0',
    s => s2,
    cout => cout2
);

sum3: FAS12b port map(
    a => s2,
    b => r3,
    s_r => '0',
    s => s3,
    cout => cout3
);

sum4: FAS12b port map(
    a => s3,
    b => r4,
    s_r => '0',
    s => s4,
    cout => cout4
);

sum5: FAS12b port map(
    a => s4,
    b => r5,
    s_r => '0',
    s => s5,
    cout => cout5
);

end Behavioral;