library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

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
        asteroid_on : in std_logic;
        alien_on : in std_logic;
        spaceship_on : out std_logic;
        missile_on : out std_logic
    );
end spaceship_graph;

architecture spaceship_arch of spaceship_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant SPACESHIP_X_SIZE : integer := 16;
    constant SPACESHIP_Y_SIZE : integer := 24;

    constant MAX_NUMBER_OF_MISSILES : integer := 200;

    signal spaceship_rom_bit : std_logic;

    signal spaceship_x_start, spaceship_x_end : unsigned(9 downto 0);
    signal spaceship_y_top, spaceship_y_bottom : unsigned(9 downto 0);

    signal spaceship_x_start_next, spaceship_y_top_next : unsigned(9 downto 0);

    signal collision_happened : std_logic;

    signal number_of_lives_next : unsigned(1 downto 0);

    signal missile_launched : std_logic;

    -- spaceship image
    type rom_type_16 is array(0 to 23) of std_logic_vector(0 to 15);
    constant SPACESHIP_ROM : rom_type_16 := (
        "0000000100000000",
        "0000001110000000",
        "0000011111000000",
        "0000111111000000",
        "0000111111100000",
        "0000111111100000",
        "0001111111100000",
        "0001111011110000",
        "0001110001110000",
        "0001111011110000",
        "0001111111110000",
        "0001111111110000",
        "0001111111110000",
        "0001111111110000",
        "0011111111111000",
        "0111111111111100",
        "0111111111111100",
        "0111111111111100",
        "0111111111111100",
        "0111111111111100",
        "0011100000011000",
        "0011000000011000",
        "0010000000001000",
        "0000000000000000"
    );

    type missile_prop is record
        missile_x_start : unsigned(9 downto 0);
        missile_y_top : unsigned(9 downto 0);
        missile_active : std_logic;
        missile_launch : std_logic;
        collision : std_logic;
        missile_on : std_logic;
    end record;

    type missiles_infos is array(0 to MAX_NUMBER_OF_MISSILES - 1) of missile_prop;
    signal info_of_missiles : missiles_infos;

    type collisions is array(0 to MAX_NUMBER_OF_MISSILES - 1) of std_logic;
    signal collision_happened_missiles : collisions;
    signal i : integer;
begin

    -- generate the missiles
    gen_missiles : for i in 0 to MAX_NUMBER_OF_MISSILES - 1 generate
        missile_graph_unit : entity work.missile_graph
            port map(
                clk => clk,
                reset => reset,
                pixel_x => pixel_x,
                pixel_y => pixel_y,
                refresh_screen => refresh_screen,
                missile_start_x => info_of_missiles(i).missile_x_start,
                missile_start_y => info_of_missiles(i).missile_y_top,
                missile_active => info_of_missiles(i).missile_active,
                missile_launch => info_of_missiles(i).missile_launch,
                collision => info_of_missiles(i).collision,
                missile_on => info_of_missiles(i).missile_on
            );
    end generate;

    process (clk)
    begin
        if (reset = '1') then
            -- map collisions
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                info_of_missiles(i).collision <= '0';
            end loop;
        elsif (rising_edge(clk)) then
            -- map collisions
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                info_of_missiles(i).collision <= collision_happened_missiles(i);
            end loop;
        end if;

    end process;
    process (clk)
    begin
        if (reset = '1') then
            -- calculate collision happened
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                collision_happened_missiles(i) <= '0';
            end loop;
        elsif (rising_edge(clk)) then
            -- calculate collision happened
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                collision_happened_missiles(i) <= '1' when (info_of_missiles(i).missile_active = '1') and ((info_of_missiles(i).missile_on = '1') and ((asteroid_on = '1') or (alien_on = '1'))) else
                '0';
            end loop;
        end if;

    end process;

    spaceship_x_end <= spaceship_x_start + SPACESHIP_X_SIZE - 1;
    spaceship_y_bottom <= spaceship_y_top + SPACESHIP_Y_SIZE - 1;

    spaceship_rom_bit <= SPACESHIP_ROM(to_integer(pixel_y) - to_integer(spaceship_y_top))(to_integer(pixel_x) - to_integer(spaceship_x_start));

    spaceship_on <= '1' when (pixel_x >= spaceship_x_start and pixel_x <= spaceship_x_end) and
        (pixel_y >= spaceship_y_top and pixel_y <= spaceship_y_bottom) and (spaceship_rom_bit = '1') else
        '0';

    number_of_lives_next <= number_of_lives - 1 when (collision_happened = '1') else
        number_of_lives;

    process (clk, reset)
    begin
        missile_on <= '0';
        if (reset = '1') then
            missile_on <= '0';
        elsif (rising_edge(clk)) then
            if (refresh_screen = '1') then
                for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                    if (info_of_missiles(i).missile_on = '1') then
                        missile_on <= '1';
                    end if;
                end loop;
            end if;
        end if;

    end process;

    -- update the spaceship position based on button presses
    process (btnl, btnr, btnu, btnd, spaceship_x_start, spaceship_y_top, spaceship_x_end, spaceship_y_bottom)
    begin
        missile_launched <= '0';
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
        elsif (btnc = '1') and (spaceship_y_top > 5) then
            -- shoot a missile
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                if (info_of_missiles(i).missile_active = '0' and missile_launched = '0') then
                    info_of_missiles(i).missile_x_start <= spaceship_x_start + to_unsigned(SPACESHIP_X_SIZE / 2 - 2, 10);
                    info_of_missiles(i).missile_y_top <= spaceship_y_top - to_unsigned(4, 10);
                    info_of_missiles(i).missile_launch <= '1';
                    missile_launched <= '1';
                end if;
            end loop;
        end if;
    end process;

    -- at reset, set the spaceship position to the center of the screen
    process (clk, reset)
    begin
        if (reset = '1') then
            spaceship_x_start <= to_unsigned(SCREEN_WIDTH / 2 - SPACESHIP_X_SIZE / 2, 10);
            spaceship_y_top <= to_unsigned(SCREEN_HEIGHT - 10 - SPACESHIP_Y_SIZE, 10);
            collision_happened <= '0';
            number_of_lives <= to_unsigned(3, 2);

            -- set the missiles inactive
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                info_of_missiles(i).missile_active <= '0';
                info_of_missiles(i).missile_launch <= '0';
                info_of_missiles(i).collision <= '0';
                info_of_missiles(i).missile_x_start <= to_unsigned(0, 10);
                info_of_missiles(i).missile_y_top <= to_unsigned(0, 10);
            end loop;
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