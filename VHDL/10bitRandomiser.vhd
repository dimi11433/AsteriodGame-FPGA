library ieee;
use ieee.std_logic_1164.all;

entity lfsr10 is
  port(
    clk : in  std_logic;
    rst : in  std_logic;
    rnd : out std_logic_vector(9 downto 0)
  );
end lfsr10;

architecture rtl of lfsr10 is
  signal reg_q   : std_logic_vector(9 downto 0);
  signal feedback: std_logic;
begin
  
  feedback <= reg_q(9) xor reg_q(6);

  process(clk, rst)
  begin
    if rst = '1' then
      reg_q <= "1010011101"; -- starter value
    elsif rising_edge(clk) then
      -- shift left, inject feedback into LSB
      reg_q <= reg_q(8 downto 0) & feedback;
    end if;
  end process;

  rnd <= reg_q;
end rtl;
