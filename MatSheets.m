clc
clear
close all

% initialize game engine
SPRITE_HEIGHT_PX = 16;
SPRITE_WIDTH_PX = 12;
SCALE = 1;
SGE_object = simpleGameEngine("ascii-shrunk.png", SPRITE_HEIGHT_PX, SPRITE_WIDTH_PX, SCALE); 

% parameters
ROW_CT = 12;
ROW_LABEL_WIDTH = 3;
COL_CT = 9;
CELL_WIDTH = 9;

HEADER_HEIGHT = 5;

% header buttons
ROW_1_BUTTONS = {'Save','Load','New','Exit'};
ROW_2_BUTTONS = {'Copy','Paste'};

% size of screen
HEIGHT = ROW_CT * 2 + 7;
WIDTH = COL_CT * (CELL_WIDTH + 1) + ROW_LABEL_WIDTH + 2;

screen = zeros(HEIGHT, WIDTH) + ' ';

% create vertical borders
for i=1:HEIGHT
    screen(i, 1) = '|';
    screen(i, 1 + ROW_LABEL_WIDTH + 1) = '|';
    screen(i, WIDTH) = '|';
end

% create bottom border
for i=1:WIDTH
    screen(HEIGHT, i) = '-';
end

% design screen
screen(1:HEADER_HEIGHT, 1:WIDTH) = buildHeader(WIDTH, ROW_1_BUTTONS, ROW_2_BUTTONS);
screen(HEADER_HEIGHT + 3:HEIGHT, 1 + ROW_LABEL_WIDTH + 2:WIDTH) = buildCells(ROW_CT, COL_CT, CELL_WIDTH);
screen(HEADER_HEIGHT + 2:HEIGHT - 1, 2:2 + ROW_LABEL_WIDTH - 1) = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH);
screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, 1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) = buildColLabels(COL_CT, CELL_WIDTH);

drawScene(SGE_object, screen)

function col_labels = buildColLabels(col_ct, cell_width)
    % Build labels for columns.
    % 
    % Input:
    %   1. # of columns
    %   2. width of the interior of a cell
    % Output:
    %   col_labels - labels for columns with a row below underlining it
    %
    % TODO - this function should be updated to be able to start from
    % a specific cell column index.

    width = col_ct * (cell_width + 1)  - 1;
    col_labels = zeros(2, width) + ' ';

    if col_ct > 26
        fprintf("ERROR: Columns > 26 not supported\n")
        quit(1)
    end

    col_label = 'A';
    for col=1:col_ct
        col_labels(1, (col - 1) * (cell_width + 1) + ceil(cell_width / 2)) = col_label;
        col_label = col_label + 1;
    end

    for i=1:width
        col_labels(2, i) = '-';
    end
end

function row_labels = buildRowLabels(row_ct, row_label_width)
    % Build labels for rows.
    % 
    % Input:
    %   1. # of rows
    %   2. width to allocate for a row label
    % Output:
    %   row_labels - labels for rows
    %
    % TODO - this function should be updated to be able to start from
    % a specific cell row index.

    row_labels = zeros(row_ct * 2, row_label_width) + ' ';
    fmt = sprintf('%%%dd', row_label_width);
    for row=1:row_ct
        row_labels(row * 2,1:row_label_width) = sprintf(fmt, row);
    end
end

function cells = buildCells(row_ct, col_ct, cell_width)
    % Build character matrix for cells.
    % 
    % Input:
    %   1. # of rows
    %   2. # of columns
    %   3. width of the interior of a cell
    % Output:
    %   cells - character matrix of cells
    %
    % TODO - this function should be updated to fill the cell contents
    % as well as the cells.

    height = row_ct * 2;
    width = col_ct * (cell_width + 1);
    cells = zeros(height, width) + ' ';
    for i=1:row_ct
        for j=1:width-1
            cells(2 * i, j) = '-';
        end
        if i == row_ct
            cells(2 * i, width) = '-';
        else
            cells(2 * i, width) = '|';
        end
    end

    for i=1:row_ct
        for j=1:col_ct
            cells(2 * i - 1, j * (cell_width + 1)) = '|';
        end
    end

end

function header = buildHeader(width, row_1_buttons, row_2_buttons)
    % Build character matrix for top header.
    % 
    % Input:
    %   1. width of screen
    %   2. cell array of character array of row 1 buttons
    %   3. cell array of character array of row 2 buttons
    % Output:
    %   header - header character matrix

    header = zeros(5, width) + ' ';
    for i=1:width
        header(1, i) = '-';
        header(3, i) = '-';
        header(5, i) = '-';
    end

    header(2, 1:width) = buildButtonHeader(width, row_1_buttons);
    header(4, 1:width) = buildButtonHeader(width, row_2_buttons);

    header(2, end - length('^   |') + 1:end) = '^   |';
    header(4, end - length('< v > |') + 1:end) = '< v > |';
end

function button_header = buildButtonHeader(width, buttons)
    % Build character array for buttons.
    % 
    % Input:
    %   1. width of screen
    %   2. cell array of character array of button names.
    % Output:
    %   button_header - button header character array

    button_header = zeros(1, width) + ' ';
    button_header(1:2) = '| ';
    i = length('| ') + 1;
    for button=buttons
        for c=button{1}
            button_header(i) = c;
            i = i + 1;
        end
        button_header(i:i+length(' | ')-1) = ' | ';
        i = i + length(' | ');
    end
end
