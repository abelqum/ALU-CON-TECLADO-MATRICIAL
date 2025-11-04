library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Multiplicador6b is
port(
    Multiplicando  : in  std_logic_vector(5 downto 0); 
    Multiplicador  : in  std_logic_vector(5 downto 0); 
    Producto_Final : out std_logic_vector(11 downto 0);
    OvF : out std_logic;
    ZF  : out std_logic;
    SF  : out std_logic;
    Cout: out std_logic
);
end Multiplicador6b;

architecture Behavioral of Multiplicador6b is

    component FAS12b is
    port(
        a, b : in  std_logic_vector(11 downto 0);
        s_r  : in  std_logic;
        s    : out std_logic_vector(11 downto 0);
        OvF, ZF, SF, Cout: out std_logic
    );
    end component;

    type tipo_pp_6b is array (0 to 5) of std_logic_vector(5 downto 0);
    signal productos_parciales_6b : tipo_pp_6b;
    
    type tipo_pp_12b is array (0 to 5) of std_logic_vector(11 downto 0);
    signal productos_desplazados_12b : tipo_pp_12b;

   
    type tipo_suma is array (0 to 4) of std_logic_vector(11 downto 0);
    signal sumas_intermedias : tipo_suma;
    signal producto_interno : std_logic_vector(11 downto 0);

begin

    generar_pp_i: for i in 0 to 5 generate
        generar_pp_j: for j in 0 to 5 generate
            productos_parciales_6b(i)(j) <= Multiplicando(j) AND Multiplicador(i);
        end generate;
    end generate;

    productos_desplazados_12b(0) <= "000000" & productos_parciales_6b(0);
    productos_desplazados_12b(1) <= "00000"  & productos_parciales_6b(1) & '0';
    productos_desplazados_12b(2) <= "0000"   & productos_parciales_6b(2) & "00";
    productos_desplazados_12b(3) <= "000"    & productos_parciales_6b(3) & "000";
    productos_desplazados_12b(4) <= "00"     & productos_parciales_6b(4) & "0000";
    productos_desplazados_12b(5) <= '0'      & productos_parciales_6b(5) & "00000";

  
    SUMADOR_0: FAS12b port map (
        a    => productos_desplazados_12b(0),
        b    => productos_desplazados_12b(1),
        s_r  => '0', 
        s    => sumas_intermedias(0),
        OvF  => open, ZF => open, 
        SF   => open, Cout => open
    );

 
    generar_sumadores_medios: for i in 1 to 3 generate
        SUMADOR_I: FAS12b port map (
            a    => sumas_intermedias(i-1),
            b    => productos_desplazados_12b(i+1),
            s_r  => '0',
            s    => sumas_intermedias(i),
            OvF  => open, ZF => open, 
            SF   => open, Cout => open
        );
    end generate;
    
 
    SUMADOR_FINAL: FAS12b port map (
        a    => sumas_intermedias(3),
        b    => productos_desplazados_12b(5), 
        s_r  => '0',
        s    => producto_interno, 
        
   
        OvF  => OvF, 
        ZF   => ZF, 
        SF   => SF, 
        Cout => Cout
    );
 

    Producto_Final <= producto_interno;

end Behavioral;
