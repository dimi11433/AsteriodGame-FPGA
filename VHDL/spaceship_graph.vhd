library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spaceship_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        btnl, btnr : in std_logic;
        btnu, btnd : in std_logic;
        btnc : in std_logic;
        refresh_screen : in std_logic;
        collision : in std_logic;
        number_of_lives : inout unsigned(1 downto 0);
        spaceship_on : out std_logic
    );
end spaceship_graph;

architecture spaceship_arch of spaceship_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant SPACESHIP_X_SIZE : integer := 16;
    constant SPACESHIP_Y_SIZE : integer := 24;

    signal spaceship_rom_bit : std_logic;

    signal spaceship_x_start, spaceship_x_end : unsigned(9 downto 0);
    signal spaceship_y_top, spaceship_y_bottom : unsigned(9 downto 0);

    signal spaceship_x_start_next, spaceship_y_top_next : unsigned(9 downto 0);

    signal collision_happened : std_logic;

    signal number_of_lives_next : std_logic_vector(1 downto 0);

    -- spaceship image
    type rom_type_16 is array(0 to 23) of std_logic_vector(0 to 15);
    constant SPACESHIP_ROM : rom_type_16 := (
        "000000010000000",
        "000000111000000",
        "000001111100000",
        "000011111100000",
        "000011111110000",
        "000011111110000",
        "000111111110000",
        "000111101111000",
        "000111000111000",
        "000111101111000",
        "000111111111000",
        "000111111111000",
        "000111111111000",
        "000111111111000",
        "001111111111110",
        "011111111111110",
        "011111111111110",
        "011111111111110",
        "011111111111110",
        "011111111111110",
        "001110000001100",
        "001100000001100",
        "000000000000000"
    );

begin
    spaceship_x_end <= spaceship_x_start + SPACESHIP_X_SIZE - 1;
    spaceship_y_bottom <= spaceship_y_top + SPACESHIP_Y_SIZE - 1;

    spaceship_rom_bit <= SPACESHIP_ROM(to_integer(pixel_y) - to_integer(spaceship_y_top))(to_integer(pixel_x) - to_integer(spaceship_x_start));

    spaceship_on <= '1' when (pixel_x >= spaceship_x_start and pixel_x <= spaceship_x_end) and
        (pixel_y >= spaceship_y_top and pixel_y <= spaceship_y_bottom) and (spaceship_rom_bit = '1') else
        '0';

    number_of_lives_next <= number_of_lives - 1 when (collision_happened = '1') else
        number_of_lives;

    -- update the spaceship position based on button presses
    process (btnl, btnr, btnu, btnd, spaceship_x_start, spaceship_y_top, spaceship_x_end, spaceship_y_bottom)
    begin
        spaceship_x_start_next <= spaceship_x_start;
        spaceship_y_top_next <= spaceship_y_top;
        if (btnl = '1') and (spaceship_x_start > 0) then
            spaceship_x_start_next <= spaceship_x_start - 1;
        elsif (btnr = '1') and (spaceship_x_end < SCREEN_WIDTH - 1) then
            spaceship_x_start_next <= spaceship_x_start + 1;
        end if;
        if (btnu = '1') and (spaceship_y_top > 0) then
            spaceship_y_top_next <= spaceship_y_top - 1;
        elsif (btnd = '1') and (spaceship_y_bottom < SCREEN_HEIGHT - 1) then
            spaceship_y_top_next <= spaceship_y_top + 1;
        end if;
    end process;

    -- at reset, set the spaceship position to the center of the screen
    process (clk, reset)
    begin
        if (reset = '1') then
            spaceship_x_start <= to_unsigned(SCREEN_WIDTH / 2 - SPACESHIP_X_SIZE / 2, 10);
            spaceship_y_top <= to_unsigned(SCREEN_HEIGHT - 10 - SPACESHIP_Y_SIZE, 10);
            collision_happened <= '0';
        elsif (rising_edge(clk)) then
            if (refresh_screen = '1') then
                if (collision_happened = '1') then
                    spaceship_x_start <= to_unsigned(SCREEN_WIDTH / 2 - SPACESHIP_X_SIZE / 2, 10);
                    spaceship_y_top <= to_unsigned(SCREEN_HEIGHT - 10 - SPACESHIP_Y_SIZE, 10);
                    collision_happened <= '0';
                else
                    spaceship_x_start <= spaceship_x_start_next;
                    spaceship_y_top <= spaceship_y_top_next;
                end if;
                number_of_lives <= number_of_lives_next;
            end if;
            if (collision = '1') then
                collision_happened <= '1';
            end if;
        end if;
    end process;
end spaceship_arch;