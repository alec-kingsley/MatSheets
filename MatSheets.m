clc
clear
close all

SGE_object = simpleGameEngine("ascii-shrunk.png",16,12,1); 

ROW_CT = 12;
ROW_LABEL_WIDTH = 3;
COL_CT = 9;
CELL_WIDTH = 9;
HEADER_HEIGHT = 5;

ROW_1_BUTTONS = {'Save','Load','New','Exit'};
ROW_2_BUTTONS = {'Copy','Paste'};

HEIGHT = ROW_CT * 2 + 7;
WIDTH = COL_CT * (CELL_WIDTH + 1) + ROW_LABEL_WIDTH + 2;

screen = zeros(HEIGHT, WIDTH) + ' ';

for i=1:HEIGHT
    screen(i, 1) = '|';
    screen(i, 1 + ROW_LABEL_WIDTH + 1) = '|';
    screen(i, WIDTH) = '|';
end
for i=1:WIDTH
    screen(HEIGHT, i) = '-';
end

screen(1:HEADER_HEIGHT, 1:WIDTH) = buildHeader(WIDTH, ROW_1_BUTTONS, ROW_2_BUTTONS);
screen(HEADER_HEIGHT + 3:HEIGHT, 1 + ROW_LABEL_WIDTH + 2:WIDTH) = buildCells(ROW_CT, COL_CT, CELL_WIDTH);
screen(HEADER_HEIGHT + 2:HEIGHT - 1, 2:2 + ROW_LABEL_WIDTH - 1) = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH);
screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, 1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) = buildColLabels(COL_CT, CELL_WIDTH);

drawScene(SGE_object, screen)

function col_labels = buildColLabels(col_ct, cell_width)
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
    row_labels = zeros(row_ct * 2, row_label_width) + ' ';
    fmt = sprintf('%%%dd', row_label_width);
    for row=1:row_ct
        row_labels(row * 2,1:row_label_width) = sprintf(fmt, row);
    end
end

function cells = buildCells(row_ct, col_ct, cell_width)
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
