library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Package Declaration
package Types is
    type char_bitmap is array (7 downto 0) of std_logic_vector(7 downto 0);

    type character_display_prop is record
        char_data : char_bitmap;
        char_width : integer;
        char_height : integer;
        char_x_start : unsigned(9 downto 0);
        char_y_top : unsigned(9 downto 0);
    end record;
end package Types;