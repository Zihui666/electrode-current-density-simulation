function SingleCircleElectrode3D
% SINGLECIRCLEELECTRODE3D
%
% 演示：在 z=0 平面上，一个半径 = 2.5 cm 的圆形电极施加 1V，
%       在 z>0 ~ 5 cm 的范围为“凝胶/皮肤”介质(电导率 sigmaGel)，
%       其上(z>5)为空气(无导电性)。
%       用 3D 有限差分 (简单迭代) 解拉普拉斯方程并可视化：
%         1) 介质中电势 + 电流分布
%         2) 在 z=0 处查看电流密度随 r 的分布 —— 这次取 0 <= r <= 2.5。
%
% 注意：示例仅用于演示思路；实际数值精度依赖网格分辨率、迭代收敛等。

    %% ------------------ 1. 定义尺寸与网格 -------------------------
    domainSize = 10;   % cm, 立方体域大小 (x,y,z 范围都 0~10)
    nElements  = 40;   % 每个方向的网格点数 (可加大以提高精度)

    [x, y, z] = meshgrid(...
        linspace(0, domainSize, nElements), ...  % X方向坐标
        linspace(0, domainSize, nElements), ...  % Y方向坐标
        linspace(0, domainSize, nElements));     % Z方向坐标

    % 网格步长(假设各向相同):
    dx = domainSize / (nElements - 1);
    dy = dx;
    dz = dx;  % 同步

    % 圆形电极的中心设在 (cx, cy) = (5, 5), 半径=2.5 cm, 在 z=0
    cx = domainSize/2;
    cy = domainSize/2;
    electrodeRadius = 2.5;  % cm
    electrodeVoltage = 1;   % V

    %% ------------------ 2. 定义材料区域与边界 ----------------------
    % 假设：z=0 ~ 5 cm 是凝胶(有导电性), z>5 cm 是空气(无导电性)
    sigmaGel = 0.003;  % S/cm, 假设凝胶/皮肤导电率
    conductivity = zeros(size(x));
    conductivity(z <= 5) = sigmaGel;  % z<=5 区域视为凝胶

    % 创建一个 3D 数组 voltage，存放节点电势。
    voltage = zeros(size(x));

    % 下面把 z=0 平面上、处于圆形电极范围 (r <= electrodeRadius) 的点固定为 5 V
    isElectrode = ((x - cx).^2 + (y - cy).^2 <= electrodeRadius^2) & (z == 0);
    voltage(isElectrode) = electrodeVoltage;

    % 电极之外(z=0, r>electrodeRadius) 也固定为 0 V
    isBottom = (z == 0);
    isOutsideElectrode = isBottom & ~isElectrode;
    voltage(isOutsideElectrode) = 0;  % 其余底面点 0 V

    %% ------------------ 3. 用简单迭代法解拉普拉斯方程 -------------
    tol = 1e-6;
    maxIter = 3000;
    for iter = 1:maxIter
        oldVoltage = voltage;

        % 只更新凝胶内部的点 (排除电极固定点, 空气, 以及网格最外层)
        for kk = 2 : (nElements-1)
            for jj = 2 : (nElements-1)
                for ii = 2 : (nElements-1)
                    if conductivity(ii,jj,kk) > 0.0  % 在凝胶区域
                        if ~isElectrode(ii,jj,kk)   % 避开电极固定电压点
                            % 拉普拉斯离散: V_ijk = avg(六邻点)
                            voltage(ii,jj,kk) = ( ...
                                oldVoltage(ii+1,jj,kk) + oldVoltage(ii-1,jj,kk) + ...
                                oldVoltage(ii,jj+1,kk) + oldVoltage(ii,jj-1,kk) + ...
                                oldVoltage(ii,jj,kk+1) + oldVoltage(ii,jj,kk-1) ) / 6;
                        end
                    end
                end
            end
        end

        % 判断收敛
        diffMax = max(abs(voltage(:) - oldVoltage(:)));
        if diffMax < tol
            disp(['Converged at iteration ', num2str(iter), ...
                  ', max diff=', num2str(diffMax)]);
            break;
        end
    end

    %% ------------------ 4. 计算电场 & 电流密度 ----------------------
    [gY, gX, gZ] = gradient(voltage, dy, dx, dz);  % axis: y->1, x->2, z->3
    Ex = -gX;
    Ey = -gY;
    Ez = -gZ;

    % J = sigma * E
    Jx = conductivity .* Ex;
    Jy = conductivity .* Ey;
    Jz = conductivity .* Ez;

    % 只在凝胶区可视化
    isGel = (z <= 5);

    %% ------------------ 5. 3D 可视化 (quiver) ----------------------
    figure('Name','3D Current in Gel','Color','w');
    quiverScale = 2;  % 箭头缩放因子
    quiver3(x(isGel), y(isGel), z(isGel), ...
            Jx(isGel), Jy(isGel), Jz(isGel), quiverScale);
    xlabel('X (cm)'); ylabel('Y (cm)'); zlabel('Z (cm)');
    title('Current Density in Gel Region');
    axis([0 domainSize 0 domainSize 0 5]);  
    axis vis3d; grid on;

    %% =========== 6. 修改此处：将 r 范围从 0~2.5 改为 0~5 =============
    % 在 z=0 处，k=1 层 (若 z=0 对应网格索引1)
    kPlane = 1; 
    Xplane = x(:,:,kPlane);
    Yplane = y(:,:,kPlane);
    Zplane = z(:,:,kPlane);  % 理论上应是0
    Jzplane = Jz(:,:,kPlane);

    % 计算半径 r (相对电极中心(cx, cy))
    rr = sqrt( (Xplane - cx).^2 + (Yplane - cy).^2 );

    % 原代码只看 r <= 2.5，现在想把范围扩大到 r <= 5
    rMaxWanted = 2.5;  % cm
    inRange = (rr <= rMaxWanted);

    rVals = rr(inRange);
    JzVals = Jzplane(inRange);

    figure('Name','Jz vs r from 0 to 5','Color','w');
    scatter(rVals, JzVals, 20, 'filled');
    xlabel('r (cm)'); ylabel('J_z (A/cm^2)');
    title('Normal Current Density vs. r at z=0 (0 <= r <= 5)');
    grid on;

    % 分桶并做平均绘制
    nBins = 30;
    edges = linspace(0, rMaxWanted, nBins+1);
    rBinCenter = 0.5*(edges(1:end-1) + edges(2:end));
    JzMean = zeros(1,nBins);

    for ib = 1:nBins
        inBin = (rVals>=edges(ib) & rVals<edges(ib+1));
        if any(inBin)
            JzMean(ib) = mean(JzVals(inBin));
        end
    end

    hold on;
    plot(rBinCenter, JzMean, 'r-o','LineWidth',1.5,'MarkerFaceColor','w');
    legend('Scatter raw','Radial bin-averaged','Location','best');
end
