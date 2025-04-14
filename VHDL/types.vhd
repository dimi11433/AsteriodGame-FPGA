-- Package Declaration
package Types is
    type char_bitmap is array (0 to 7) of std_logic_vector(7 downto 0);
    type missile_rom is array (0 to 7) of std_logic_vector(7 downto 0);

    type character_display_prop is record
        char_data : char_bitmap;
        char_width : integer;
        char_height : integer;
        char_x_start : unsigned(9 downto 0);
        char_y_top : unsigned(9 downto 0);
    end record;

    type missile_prop is record
        missile_data : missile_rom;
        missile_x_start : unsigned(9 downto 0);
        missile_y_top : unsigned(9 downto 0);
        missile_x_end : unsigned(9 downto 0);
        missile_y_bottom : unsigned(9 downto 0);
    end record;
end package Types;