Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity TCD is
    port(
        leds: out std_logic_vector(3 downto 0);
        fila : in std_logic_vector(3 downto 0);
        columnas : out std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        seg: out std_logic_vector(0 to 7);
        an: out std_logic_vector(3 downto 0);
        ledsd: out std_logic_vector(3 downto 0)
    );
end TCD;

Architecture Behavioral of TCD is

    component Calculadora is
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
    end component;

    component display is
        Port (
            Datos : in std_logic_vector(15 downto 0);
            clk_27mhz : in STD_LOGIC;
            signo : in STD_LOGIC;
            seg : out STD_LOGIC_VECTOR(0 to 7);
            an : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component teclado is
        Port (
            clk_27mhz : in STD_LOGIC;
            reset : in STD_LOGIC;
            fila : in std_logic_vector(3 downto 0);
            columnas : out std_logic_vector(3 downto 0);
            enter_out : out std_logic;
            numero : out std_logic_vector(15 downto 0)
        );
    end component;

    signal calc_resultado, Areg, Breg, OpReg, Intermediario, salida_teclado : std_logic_vector(15 downto 0);
    
                           
    signal enter_sal : std_logic;
    
    type estados is (num1, num2, op, res);
    signal presente, siguiente: estados;
    
    signal s_flag_CF  : std_logic;
    signal s_flag_ZF  : std_logic;
    signal s_flag_SF  : std_logic;
    signal s_flag_OvF : std_logic;
    signal s_error_div: std_logic;
    
    signal signo_para_display : std_logic;

begin

    TECLADO_INST: teclado
        port map(
            clk_27mhz => clk,
            reset => reset,
            fila => fila,
            columnas => columnas,
            enter_out => enter_sal,
            numero => salida_teclado
        );

    CALCULADORA_INST: Calculadora
        port map(
            A => Areg,
            B => Breg,
            sel => OpReg(3 downto 0),
            clk => clk,
            reset => reset,
            resultado => calc_resultado,
            error_div => s_error_div,
            flag_CF  => s_flag_CF,
            flag_ZF  => s_flag_ZF,
            flag_SF  => s_flag_SF,
            flag_OvF => s_flag_OvF
        );

    signo_para_display <= '1' when (presente = res) and (s_flag_SF = '1') else '0';
    
    DISPLAY_INST: display
        port map(
            Datos => Intermediario,
            clk_27mhz => clk,
            signo => signo_para_display,
            seg => seg,
            an => an
        );

    ledsd <= s_flag_CF & s_flag_ZF & s_flag_SF & s_flag_OvF;

 
    
    process(clk, reset)
    begin
        if reset = '0' then
            presente <= num1;
        elsif rising_edge(clk) then
            presente <= siguiente;
        end if;
    end process;

   
    process(clk, reset)
    begin
        if reset = '0' then
            Areg <= (others => '0');
            Breg <= (others => '0');
            OpReg <= (others => '0');
            siguiente <= num1;
        elsif rising_edge(clk) then
            case presente is
                when num1 => 
                    leds <= "0001";
                    Areg <= salida_teclado;
                    Intermediario <= Areg;
                    if enter_sal = '1' then
                        siguiente <= num2;
                    end if;
                    
                when num2 => 
                    leds <= "0010";
                    Breg <= salida_teclado;
                    Intermediario <= Breg;
                    if enter_sal = '1' then 
                        siguiente <= op;
                    end if;
                    
                when op => 
                    leds <= "0100";
                OpReg <= (others => '0');
                OpReg(3 downto 0) <= salida_teclado(3 downto 0); 
                Intermediario <= "111111111111" & salida_teclado(3 downto 0);
                    if enter_sal = '1' then
                        siguiente <= res;
                    end if;
                    
                when res => 
                    leds <= "1000";
                    Intermediario <= calc_resultado;
                    if enter_sal = '1' then
                        siguiente <= op;
                    end if;
                    
                when others =>
                    siguiente <= num1;
            end case;
        end if;
    end process;

end Behavioral;
