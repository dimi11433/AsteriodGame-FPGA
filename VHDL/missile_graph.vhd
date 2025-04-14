library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity missile_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        refresh_screen : in std_logic;
        missile_start_x : in unsigned(9 downto 0);
        missile_start_y : in unsigned(9 downto 0);
        missile_active : inout std_logic;
        missile_launch : inout std_logic;
        collision : in std_logic;
        missile_on : out std_logic;
    );
end missile_graph;


architecture missile_arch of missile_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant MISSILE_SIZE : integer := 4;

    constant MISSILE_DY : integer := 1;

    type missile_rom is array (0 to 3) of std_logic_vector(3 downto 0);
    constant MISSILE_BITMAP : missile_rom := (
         "0110",  -- Row 0
         "1111",  -- Row 1
         "1111",  -- Row 2
         "0110"   -- Row 3
    );

    signal missile_rom_bit : std_logic;

    signal missile_x_start, missile_x_end : unsigned(9 downto 0);
    signal missile_y_top, missile_y_bottom : unsigned(9 downto 0);
    signal missile_x_start_next, missile_y_top_next : unsigned(9 downto 0);

begin
    missile_rom_bit <= MISSILE_BITMAP(to_integer(pixel_y) - to_integer(missile_y_top))(to_integer(pixel_x) - to_integer(missile_x_start));

    missile_x_end <= missile_x_start + to_unsigned(MISSILE_SIZE, 10);
    missile_y_bottom <= missile_y_top + to_unsigned(MISSILE_SIZE, 10);

    missile_on <= '1' when (pixel_x >= missile_x_start and pixel_x <= missile_x_end) and
        (pixel_y >= missile_y_top and pixel_y <= missile_y_bottom) and (missile_rom_bit = '1') and (missile_active = '1') else
        '0';

    missile_y_top_next <= missile_y_top - to_unsigned(MISSILE_DY, 10);

    -- move the missile
    process(clk, reset)
    begin
        if reset = '1' then
            missile_x_start <= to_unsigned(0, 10);
            missile_y_top <= to_unsigned(0, 10);
        elsif rising_edge(clk) then
            if refresh_screen = '1' and missile_active = '1' then
                if missile_y_top == to_unsigned(0, 10) then
                    missile_active <= '0';
                else
                    missile_y_top <= missile_y_top_next;
                end if;
            end if;
        end if;
    end process;

    -- at collision, set the missile to inactive and at launch, set it to active
    process(collision)
    begin
        if collision = '1' then
            missile_active <= '0';
        end if;
    end process;


    -- when the missile is launched, set its position and activate it
    process(missile_launch)
    begin
        if missile_launch = '1' then
            missile_x_start <= missile_start_x;
            missile_y_top <= missile_start_y;
            missile_active <= '1';
            missile_launch <= '0';
        end if;
    end process;
end missile_arch;
