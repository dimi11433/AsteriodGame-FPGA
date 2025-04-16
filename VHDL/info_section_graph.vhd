library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.ALL;

entity info_section_graph is
    generic (
        SCREEN_WIDTH       : integer := 640;
        SCREEN_HEIGHT      : integer := 480;
        INFO_LEFT          : unsigned(9 downto 0) := to_unsigned(100, 10);
        INFO_RIGHT         : unsigned(9 downto 0) := to_unsigned(102, 10);
        INFO_TOP           : unsigned(9 downto 0) := to_unsigned(40,  10);
        INFO_BOTTOM        : unsigned(9 downto 0) := to_unsigned(42,  10);
        TEXT_X_START       : unsigned(9 downto 0) := to_unsigned(10,  10);
        TEXT_Y_TOP         : unsigned(9 downto 0) := to_unsigned(10,  10);
        TEXT_X_END         : unsigned(9 downto 0) := to_unsigned(18,  10);
        TEXT_Y_BOTTOM      : unsigned(9 downto 0) := to_unsigned(18,  10)
    );
    port (
        i_clk             : in  std_logic;
        i_reset_n         : in  std_logic;
        i_pixel_x         : in  unsigned(9 downto 0);
        i_pixel_y         : in  unsigned(9 downto 0);
        i_refresh_screen  : in  std_logic;
        i_collision       : in  std_logic;
        i_number_of_lives : in  unsigned(1 downto 0);
        o_info_on         : out std_logic
    );
end entity info_section_graph;

architecture rtl of info_section_graph is
    -- Internal signals
    signal s_char_addr     : unsigned(7 downto 0);
    signal s_char_data     : char_bitmap;
    signal s_left_bar_on   : std_logic;
    signal s_bottom_bar_on : std_logic;
    signal s_text_on       : std_logic;
begin

    ----------------------------------------------------------------------------
    -- Character ROM instantiation
    ----------------------------------------------------------------------------
    rom_inst: entity work.get_character_rom
        port map (
            char_addr => s_char_addr,
            char_data => s_char_data
        );

    ----------------------------------------------------------------------------
    -- Address generation process (synchronous, active-low reset)
    ----------------------------------------------------------------------------
    addr_proc: process(i_clk, i_reset_n)
    begin
        if i_reset_n = '0' then
            s_char_addr <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_refresh_screen = '1' then
                s_char_addr <= resize(i_number_of_lives, 8);
            end if;
        end if;
    end process addr_proc;

    ----------------------------------------------------------------------------
    -- Combinational drawing logic
    ----------------------------------------------------------------------------
    draw_proc: process(i_pixel_x, i_pixel_y, s_char_data)
        variable v_row : integer range 0 to 7;
        variable v_col : integer range 0 to 7;
    begin
        -- Left vertical bar
        if (i_pixel_x >= INFO_LEFT) and (i_pixel_x <= INFO_RIGHT)
           and (i_pixel_y <= INFO_BOTTOM) then
            s_left_bar_on <= '1';
        else
            s_left_bar_on <= '0';
        end if;

        -- Bottom horizontal bar
        if (i_pixel_x <= INFO_RIGHT)
           and (i_pixel_y >= INFO_TOP) and (i_pixel_y <= INFO_BOTTOM) then
            s_bottom_bar_on <= '1';
        else
            s_bottom_bar_on <= '0';
        end if;

        -- Text region
        if (i_pixel_x >= TEXT_X_START) and (i_pixel_x <= TEXT_X_END)
           and (i_pixel_y >= TEXT_Y_TOP) and (i_pixel_y <= TEXT_Y_BOTTOM) then
            v_row := to_integer(i_pixel_y - TEXT_Y_TOP);
            v_col := to_integer(i_pixel_x - TEXT_X_START);
            s_text_on <= s_char_data(v_row)(v_col);
        else
            s_text_on <= '0';
        end if;
    end process draw_proc;

    ----------------------------------------------------------------------------
    -- Combine all elements
    ----------------------------------------------------------------------------
    o_info_on <= s_left_bar_on or s_bottom_bar_on or s_text_on;

end architecture rtl;
