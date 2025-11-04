Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity ALU12bits is
    port(
        A : in std_logic_vector(11 downto 0);      -- Operando A
        B : in std_logic_vector(11 downto 0);      -- Operando B
        sel : in std_logic_vector(3 downto 0);     -- Selector de operación
        clk : in std_logic;                        -- Reloj para mult/div
        reset : in std_logic;                      -- Reset para mult/div
        resultado : out std_logic_vector(11 downto 0); -- Resultado
        resto : out std_logic_vector(5 downto 0);      -- Resto de división
        c_out : out std_logic;                     -- Acarreo
        error_div : out std_logic                  -- Error división por cero
    );
end ALU12bits;

Architecture Behavioral of ALU12bits is
    
    component FAS12b is
        port(
            a, b : in std_logic_vector(11 downto 0);
            s_r : in std_logic;
            s   : out std_logic_vector(11 downto 0);
            cout : out std_logic
        );
    end component;

    component Multiplicador is
        port(
            A, B : in std_logic_vector(5 downto 0);
            clk, reset : in std_logic;
            Resultado : out std_logic_vector(11 downto 0)
        );
    end component;
    
    component Divisor is
        port(
            A, B : in std_logic_vector(5 downto 0);
            clk, reset, Activar : in std_logic;
            Resultado : out std_logic_vector(11 downto 0);
            Resto : out std_logic_vector(5 downto 0);
            error_division_cero : out std_logic
        );
    end component;
    
    -- Señales para la suma de 8 bits
    signal a8b, b8b, uno, nota, notb : std_logic_vector(11 downto 0);
    signal a6b, b6b : std_logic_vector(5 downto 0);
    
    --resultados
    signal suma8b, resta8b, aMas1, bMas1, aMenos1, bMenos1 : std_logic_vector(11 downto 0);
    signal suma12b, resta12b, and12, or12, xor12, c2a, c2b, axb, aentreb : std_logic_vector(11 downto 0);
    
    --couts
    signal suma8bCOUT, resta8bCOUT, aMas1COUT, bMas1COUT : std_logic;
    signal aMenos1COUT, bMenos1COUT, suma12bCOUT, resta12bCOUT, c2aCOUT, c2bCOUT : std_logic;
    
    -- Señal de activación para el divisor
    signal Activar_div : std_logic;
        
begin

    a6b <= A(5 downto 0);
    b6b <= B(5 downto 0);
    a8b <= "0000" & A(7 downto 0);
    b8b <= "0000" & B(7 downto 0);
    uno <= "000000000001";
    nota <= not A;
    notb <= not B;
    
    -- Señal de activación para el divisor (solo cuando sel = "1110")
    Activar_div <= '1' when sel = "1110" else '0';

    -- Suma de 8 bits
    fas_sum8: FAS12b port map(
        a => a8b, 
        b => b8b, 
        s_r => '0',
        s => suma8b, 
        cout => suma8bCOUT
    );

    -- RESTA 8 BITS
    fas_rest8: FAS12b port map(
        a => a8b, 
        b => b8b, 
        s_r => '1',
        s => resta8b, 
        cout => resta8bCOUT
    );
    
    -- A+1
    fas_aMas1: FAS12b port map(
        a => A, 
        b => uno, 
        s_r => '0',
        s => aMas1, 
        cout => aMas1COUT
    );

    -- A-1
    fas_aMenos1: FAS12b port map(
        a => A, 
        b => uno, 
        s_r => '1',
        s => aMenos1, 
        cout => aMenos1COUT
    );
    
    -- B+1
    fas_bMas1: FAS12b port map(
        a => B, 
        b => uno, 
        s_r => '0',
        s => bMas1, 
        cout => bMas1COUT
    );
    
    -- B-1
    fas_bMenos1: FAS12b port map(
        a => B, 
        b => uno, 
        s_r => '1',
        s => bMenos1, 
        cout => bMenos1COUT
    );

    -- Suma de 12 bits
    fas_sum12: FAS12b port map(
        a => A, 
        b => B, 
        s_r => '0',
        s => suma12b, 
        cout => suma12bCOUT
    );

    -- RESTA 12 BITS
    fas_rest12: FAS12b port map(
        a => A, 
        b => B, 
        s_r => '1',
        s => resta12b, 
        cout => resta12bCOUT
    );
    
    -- Operaciones lógicas
    and12 <= A and B;
    or12 <= A or B;
    xor12 <= A xor B;

    -- COMPLEMENTO A2 DE A
    fas_compa: FAS12b port map(
        a => nota, 
        b => uno, 
        s_r => '0',
        s => c2a, 
        cout => c2aCOUT
    );
    
    -- COMPLEMENTO A2 DE B
    fas_compb: FAS12b port map(
        a => notb, 
        b => uno, 
        s_r => '0',
        s => c2b, 
        cout => c2bCOUT
    );

    -- MULTIPLICACIÓN DE A*B
    mult_axb: Multiplicador port map(
        A => a6b,
        B => b6b,
        clk => clk,
        reset => reset,
        Resultado => axb
    );
    
    -- DIVISIÓN DE A/B (con señal de activación)
    div_aentreb: Divisor port map(
        A => a6b,
        B => b6b,
        clk => clk,
        reset => reset,
        Activar => Activar_div,  -- Señal de activación
        Resultado => aentreb,
        Resto => resto,
        error_division_cero => error_div
    );
    
    -- Asignar salidas del resultado
    with sel select
    Resultado <= 
        suma8b when "0000",
        resta8b when "0001",
        aMas1 when "0010",
        aMenos1 when "0011",
        bMas1 when "0100",
        bMenos1 when "0101",
        suma12b when "0110",
        resta12b when "0111",
        and12 when "1000",
        or12 when "1001",
        xor12 when "1010",
        c2a when "1011",
        c2b when "1100",
        axb when "1101",
        aentreb when "1110",
        (others => '0') when others;
    
    -- Asignar salidas de acarreo
    with sel select
    c_out <= 
        suma8bCOUT when "0000",
        resta8bCOUT when "0001",
        aMas1COUT when "0010",
        aMenos1COUT when "0011",
        bMas1COUT when "0100",
        bMenos1COUT when "0101",
        suma12bCOUT when "0110",
        resta12bCOUT when "0111",
        '0' when "1000",
        '0' when "1001",
        '0' when "1010",
        c2aCOUT when "1011",
        c2bCOUT when "1100",
        '0' when "1101",
        '0' when "1110",
        '0' when others;
   
end Behavioral;