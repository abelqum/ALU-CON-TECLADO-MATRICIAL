Library IEEE;
Use IEEE.std_logic_1164.all;

Entity FAS12b is
    port(
        a, b : in std_logic_vector(11 downto 0);
        s_r : in std_logic;
        s   : out std_logic_vector(11 downto 0);
        cout : out std_logic
    );
end FAS12b;

architecture behavioral of FAS12b is

    component FAS is
        port(
            a, b, c_in, x : in std_logic;
            s, c_out : out std_logic
        );
    end component;

    signal c : std_logic_vector(12 downto 0);

begin

    gen: for i in 0 to 11 generate
        fas_inst: FAS port map(
            a => a(i),
            b => b(i),
            c_in => c(i),
            x => s_r,
            s => s(i),
            c_out => c(i + 1)
        );
    end generate;

    c(0) <= s_r;
    cout <= c(12);

end behavioral;
