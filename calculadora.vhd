Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Calculadora is
    port(
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        sel : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        resultado : out std_logic_vector(15 downto 0);
        error_div : out std_logic;
        flag_CF  : out std_logic;
        flag_ZF  : out std_logic;
        flag_SF  : out std_logic;
        flag_OvF : out std_logic
    );
end Calculadora;

Architecture Behavioral of Calculadora is
    
    component ALU12bits is
        port(
            A : in std_logic_vector(11 downto 0);
            B : in std_logic_vector(11 downto 0);
            sel : in std_logic_vector(3 downto 0);
            resultado : out std_logic_vector(11 downto 0);
            residuo : out std_logic_vector(5 downto 0);
            CF : out std_logic;
            ZF: out std_logic;
            SF: out std_logic;
            OvF: out std_logic;
            error_div : out std_logic
        );
    end component;

    component bcdbin is
        Port ( 
            clk, reset: in std_logic;
            bcd     : in  STD_LOGIC_VECTOR (15 downto 0);
            binario : out STD_LOGIC_VECTOR (11 downto 0)
        );
    end component;

    -- --- COMPONENTE BINBCD MODIFICADO ---
    component binbcd is
        Port ( 
            clk, reset: in std_logic;
            binario : in  STD_LOGIC_VECTOR (11 downto 0);
            signo   : in  std_logic; -- PUERTO AÑADIDO
            bcd     : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;
       
    signal binarioA,binarioB,resultadoALU: std_logic_vector(11 downto 0);
    signal restoALU: std_logic_vector(5 downto 0):=(others=>'0');
    
    -- --- SEÑALES INTERNAS NUEVAS PARA FLAGS ---
    signal s_flag_CF  : std_logic;
    signal s_flag_ZF  : std_logic;
    signal s_flag_SF  : std_logic;
    signal s_flag_OvF : std_logic;

begin

    BCD_to_BINA: bcdbin 
        port map(
            clk => clk,
            reset => reset,
            bcd => A,
            binario => binarioA
        );

    BCD_to_BINB: bcdbin 
        port map(
            clk => clk,
            reset => reset,
            bcd => B,
            binario => binarioB
        );

    -- --- ALU_INSTANCIA MODIFICADA ---
    ALU_instancia: ALU12bits 
        port map(
            A => binarioA,
            B => binarioB,
            sel => sel,
            resultado => resultadoALU,
            residuo   => restoALU,
            error_div => error_div,
            CF  => s_flag_CF, -- Conectar a señal interna
            ZF  => s_flag_ZF, -- Conectar a señal interna
            SF  => s_flag_SF, -- Conectar a señal interna
            OvF => s_flag_OvF  -- Conectar a señal interna
        );

    -- --- BIN_TO_BCD MODIFICADO ---
    BIN_to_BCD: binbcd 
        port map(
            clk => clk,
            reset => reset,
            binario => resultadoALU,
            signo   => s_flag_SF, -- Pasar la señal de signo
            bcd => resultado
        );
        
    -- --- Asignar señales internas a puertos de salida ---
    flag_CF <= s_flag_CF;
    flag_ZF <= s_flag_ZF;
    flag_SF <= s_flag_SF;
    flag_OvF <= s_flag_OvF;
        
end Behavioral;
