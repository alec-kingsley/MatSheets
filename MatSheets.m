clc
clear
close all

% initialize game engine
SPRITE_HEIGHT_PX = 16;
SPRITE_WIDTH_PX = 12;
SCALE = 1;
SGE = simpleGameEngine("ascii-shrunk.png", SPRITE_HEIGHT_PX, ...
                       SPRITE_WIDTH_PX, SCALE); 

% initialize sheet data
DATA = SheetData();

% parameters
ROW_CT = 10;
ROW_LABEL_WIDTH = 3;
COL_CT = 7;
CELL_WIDTH = 9;

HEADER_HEIGHT = 5;

% header buttons
ROW_1_BUTTONS = {'Save As','Load','New','Exit'};
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

TOP_LEFT_Y_POS = HEADER_HEIGHT + 3;
TOP_LEFT_X_POS = ROW_LABEL_WIDTH + 3;

% design screen
screen(1:HEADER_HEIGHT, 1:WIDTH) ...
    = buildHeader(WIDTH, ROW_1_BUTTONS, ROW_2_BUTTONS);
screen(TOP_LEFT_Y_POS:HEIGHT, TOP_LEFT_X_POS:WIDTH) ...
    = buildCellBorders(ROW_CT, COL_CT, CELL_WIDTH);
screen(HEADER_HEIGHT + 2:HEIGHT - 1, 2:2 + ROW_LABEL_WIDTH - 1) ...
    = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH);
screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, ...
       1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) ...
    = buildColLabels(COL_CT, CELL_WIDTH);

SGE.drawScene(screen);

% for scrolling capabilities
top_left_row = 1;
top_left_col = 1;

exit_clicked = false;
while ~exit_clicked
    screen(TOP_LEFT_Y_POS:HEIGHT, TOP_LEFT_X_POS:WIDTH) ...
        = buildCells(ROW_CT, COL_CT, CELL_WIDTH, 1, 1, DATA);
    SGE.drawScene(screen);
    [row, col, button] = SGE.getMouseInput();
    button_clicked = getHeaderButton(row, col, ROW_1_BUTTONS, ...
                                       ROW_2_BUTTONS);
    if isempty(button_clicked)
        % test if it's a cell
        [cell_row, cell_col] = getCellPos(row, col, TOP_LEFT_Y_POS, ...
                                          TOP_LEFT_X_POS, CELL_WIDTH);

        if cell_row == 0 && cell_col == 0
            fprintf("Click target unknown.\n");
        else
            fprintf("Cell clicked: %c%d\n", 'A' + cell_col - 1, cell_row);
            old_value = DATA.getCellValue(cell_row, cell_col);
            input_str = getInput(SGE, screen, 'Value', old_value, WIDTH);
            DATA.setCellValue(cell_row, cell_col, input_str);
        end

    else
        fprintf("Button clicked: %s\n", button_clicked)
        if strcmp(button_clicked, 'Exit') == 1
            exit_clicked = true;
            close(SGE.my_figure);
        elseif strcmp(button_clicked, 'Save As') == 1
            input_str = getInput(SGE, screen, 'File name', '', WIDTH);
            if ~isempty(input_str)
                DATA.toCSV(input_str);
            end
        elseif strcmp(button_clicked, 'Load') == 1
            input_str = getInput(SGE, screen, 'File name', '', WIDTH);
            if ~isempty(input_str)
                DATA.fromCSV(input_str);
            end
        elseif strcmp(button_clicked, 'New') == 1
            DATA.reset();
        elseif strcmp(button_clicked, 'Copy') == 1
            [cell_row, cell_col] = selectCell(SGE, TOP_LEFT_Y_POS, ...
                                              TOP_LEFT_X_POS, CELL_WIDTH);
            clipboard('copy', DATA.getCellValue(cell_row, cell_col));
        elseif strcmp(button_clicked, 'Paste') == 1
            [cell_row, cell_col] = selectCell(SGE, TOP_LEFT_Y_POS, ...
                                              TOP_LEFT_X_POS, CELL_WIDTH);
            DATA.setCellValue(cell_row, cell_col, clipboard('paste'));
        end

    end
end

function [cell_row, cell_col] = selectCell(sge, top_left_y_pos, ...
                                           top_left_x_pos, cell_width)
    % Force user to select a cell and return its position.
    %
    % Input:
    %   1. the SGE object
    %   2. the y offset of the top left character
    %   3. the x offset of the top left character
    %   4. the width of a cell

    cell_row = 0;
    cell_col = 0;
    while cell_row == 0 && cell_col == 0
        [row, col, button] = sge.getMouseInput();
        [cell_row, cell_col] = getCellPos(row, col, top_left_y_pos, ...
                                          top_left_x_pos, cell_width);
    end
end

function [cell_row, cell_col] = getCellPos(row, col, top_left_y_pos, ...
                                           top_left_x_pos, cell_width)
    % Get the cell row and column clicked from the cursor position
    %
    % Input:
    %   1. the row of the character clicked
    %   2. the row of the character clicked
    %   3. the y offset of the top left character
    %   4. the x offset of the top left character
    %   5. the width of a cell
                                         
    cell_row = 0;
    cell_col = 0;

    if mod(row - top_left_y_pos, 2) == 0 ...
        && mod(col - top_left_x_pos, cell_width + 1) ~= cell_width ...
        && row >= top_left_y_pos && col >= top_left_x_pos

        cell_row = (row - top_left_y_pos) / 2 + 1;
        cell_col = floor((col - top_left_x_pos) ...
                         / (cell_width + 1)) + 1;
    end
end

function input_str = getInput(sge, screen, prompt, default, width)
    % Get input from the user. Return `default`
    % if the user presses `esc`.
    %
    % Input:
    %   1. the SGE object
    %   2. the previous screen
    %   3. the prompt to give the user
    %   4. the width of the screen

    printTextBox(sge, screen, [prompt ': ' default], width);
    key = ' ';
    input_str = default;
    while strcmp(key, 'return') ~= 1 && strcmp(key, 'escape') ~= 1
        key = getKey(sge);
        if length(key) == 1
            input_str = [input_str key];
        elseif strcmp(key, 'backspace') == 1
            input_str = input_str(1:end-1);
        end
        printTextBox(sge, screen, [prompt ': ' input_str], width);
    end
    if strcmp(key, 'escape')
        input_str = default;
    end
end

function printTextBox(sge, screen, contents, width)
    % Print a text box to replace the top buttons
    %
    % Input:
    %   1. the SGE object
    %   2. the previous screen
    %   3. the contents to print
    %   4. the width of the screen

    screen(3, 1) = '|';
    screen(3, 2) = ' ';
    screen(3, width) = '|';
    screen(3, width - 1) = ' ';

    contents_idx = 1;

    for i=2:4
        for j=3:width-2
            if contents_idx <= length(contents)
                screen(i, j) = contents(contents_idx);
                contents_idx = contents_idx + 1;
            else
                screen(i, j) = ' ';
            end
        end
    end
    sge.drawScene(screen);
end

function key = getKey(sge)
    % Get keyboard input from SGE as a character, rather than character name.
    %
    % Input:
    %   1. the SGE object

    SYMBOL_NAMES = {'space', 'comma', 'period', 'semicolon', 'quote',...
        'slash', 'hyphen', 'leftbracket', 'rightbracket', 'equal',...
        'backquote', 'backslash','tab'};
    SYMBOL_VALUES = {' ', ',','.',';','''','/','-','[',']','=','`','\',sprintf('\t')};
    symblify = dictionary(SYMBOL_NAMES, SYMBOL_VALUES);

    key = getKeyboardInput(sge);
    if ismember(key, SYMBOL_NAMES)
        key = symblify({key});
    end
    key = processShift(key, sge.my_figure);
end

function key = processShift(key, fig)
    % Apply shift key, if pressed.    
    %
    % Input: 
    %   1. the key pressed
    %   2. the figure for the SGE object
    % Output: 
    %   key - the modified key
    %

    modifiers = get(fig, 'CurrentModifier');
    LOWERCASE_VALUES = {
        '1','2','3','4','5',...
        '6','7','8','9','0',...
        ';','''','/','-','[',...
        ']','=','á','é','í',...
        'ó','ú','ñ','ü','`',...
        '\',',','.','þ','ð',...
        'ġ','ċ',
    };
    UPPERCASE_VALUES = {
        '!','@','#','$','%',...
        '^','&','*','(',')',...
        ':','"','?','_','{',...
        '}','+','Á','É','Í',...
        'Ó','Ú','Ñ','Ü','~',...
        '|','<','>','Þ','Ð',...
        'Ġ','Ċ',
    };
    key = char(key);
    if ismember('shift',modifiers)
        if ismember(key, LOWERCASE_VALUES)
            dict = dictionary(LOWERCASE_VALUES, UPPERCASE_VALUES);
            key = dict({key});
        elseif isscalar(key) && key <= 'z' && key >= 'a'
            key = key + 'A' - 'a';
        end
    end
    key = char(key);
end

function button = getHeaderButton(row, col, row_1_buttons, row_2_buttons)
    % Get header button at (row, col) as a character array,
    % or return empty character array if header button not clicked.
    % 
    % Input:
    %   1. row
    %   2. column
    % Output:
    %   button - button at specified position

    ROW_1 = 2;
    ROW_2 = 4;

    button = '';

    if row == ROW_1
        row_buttons = row_1_buttons;
    elseif row == ROW_2
        row_buttons = row_2_buttons;
    else
        row_buttons = {};
    end
    
    i = length('| ') + 1;
    for row_button=row_buttons
        for c=row_button{1}
            if i == col
                button = row_button{1};
            end
            i = i + 1;
        end
        i = i + length(' | ');
    end
end

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
        col_labels(1, (col - 1) * (cell_width + 1) ...
                      + ceil(cell_width / 2)) ...
            = col_label;
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

function cells = buildCells(row_ct, col_ct, cell_width, ...
                            top_left_row, top_left_col, data)
    % Build character matrix for cells.
    % 
    % Input:
    %   1. # of rows
    %   2. # of columns
    %   3. width of the interior of a cell
    %   4. row idx of top left cell
    %   5. col idx of top left cell
    % Output:
    %   cells - character matrix of cells

    cells = buildCellBorders(row_ct, col_ct, cell_width);
    for row=1:row_ct
        for col=1:col_ct
            col_off = (cell_width + 1) * (col - 1) + 1;
            row_idx = top_left_row + row - 1;
            col_idx = top_left_col + col - 1;
            cells(row * 2 - 1, col_off:col_off + cell_width - 1) ...
                = data.getCellStr(row_idx, col_idx, cell_width);
        end
    end

end

function cells = buildCellBorders(row_ct, col_ct, cell_width)
    % Build character matrix for cell borders.
    % 
    % Input:
    %   1. # of rows
    %   2. # of columns
    %   3. width of the interior of a cell
    % Output:
    %   cells - character matrix of cells

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

    % TODO - update below when scrolling is added
    header(2, end - length(' |') + 1:end) = ' |';
    header(4, end - length(' |') + 1:end) = ' |';
    %header(2, end - length('^   |') + 1:end) = '^   |';
    %header(4, end - length('< v > |') + 1:end) = '< v > |';
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
