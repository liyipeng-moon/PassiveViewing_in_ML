function createHeatmap(data)
    % 输入参数data是一个100000x2的矩阵，包含坐标xy随着时间的变化

    % 将数据转换为概率密度矩阵
    x = data.LastTrialAnalogData.Eye(:, 1); % 提取x坐标
    y = data.LastTrialAnalogData.Eye(:, 2); % 提取y坐标

    % 设置网格大小和范围
    gridSize = 60; % 网格大小，可以根据需要调整
    xEdges = linspace(-20, 20, gridSize);
    yEdges = linspace(-20, 20, gridSize);

    % 创建直方图
    histogram2D = histcounts2(x, y, xEdges, yEdges);

    % 将直方图归一化为概率密度
    probabilityDensity = histogram2D / sum(histogram2D(:));

    c = imagesc(probabilityDensity);
    axis equal; axis off
    colorbar
    colormap('hot')

    % 添加标题和标签
    title('Probability Density Heatmap')
    

end
