%% ɨ�ػ�����ģ�⣬������
function [step_num_plan, step_num_random] = robot_sweeper()
% ���������������ʵ��ȫ���ǵ����д���
%��դ��ģ�͵�ÿһ��դ�񿴳�һ����
%ʵ����դ��ģ���������ģ��ڼ��������ʱ������ɢ��

%��դ��ģ�ͳ���Ϊ��ʶ���󣬾����Ӧλ�õı�Ǳ�ʾդ���Ӧλ�õ�״̬
%0��ʾ��Ӧλ�����ϰ��1��ʾ��Ӧλ�����ϰ���

%��������
size = 1; %ɨ�ػ����˵ĳߴ�
map_x = 20; %����ĳߴ�
map_y = 15;

%���ɵ�ͼ�����Ӧ�ı�ʶ����
tag = zeros(map_x, map_y);
%��������ϰ��Ҳ��ͨ����������
Tag = barrier_generate(tag);
Tag(1, 1) = 0;
%����ͼ���ڽ�ѹ����
b = graph_convert(Tag);
[re, node_num] = DFS(b, Tag);
step_num_plan = length(re);
result_display(re, Tag);
%���������ײ����չʾ
step_num_random = random_display(Tag, node_num);
%% ���ɱ�Ǿ���
function Tag = barrier_generate(Tag)
x_num = 3;
y_num = 2;
[map_x, map_y] = size(Tag);
x_1 = round(map_x / x_num); %���ڵ�ͼ����̫С��ʱ�����
x_2 = round(map_x * 2 / x_num);
y_1 = round(map_y / y_num);
x_area = [0 x_1 x_2 map_x];
y_area = [0 y_1 map_y];
for i = 1:length(x_area) - 1
    for j = 1:length(y_area) - 1
        temp_x = x_area(i+1) - x_area(i);
        temp_y = y_area(j+1) - y_area(j);
        obs_1 = round(rand(temp_x, temp_y));
        obs_2 = round(rand(temp_x, temp_y));
        obs = conjunction(obs_1, obs_2); %ȡ�����������ĺ�ȡ��֤��ͨ·
        Tag([x_area(i)+1:x_area(i+1)], [y_area(j)+1:y_area(j+1)]) = obs;
    end
end
%% �����ϰ����barrier_generate���Ӻ���
function obs = conjunction(obs_1, obs_2)
[map_x, map_y] = size(obs_1);
for i = 1:map_x
    for j = i:map_y
        if obs_1(i,j) == 1 & obs_2(i,j) == 1
            obs(i,j) = 1;
        else obs(i,j) = 0;
        end
    end
end
%% �����������
function [re, node_num] = DFS(b, Tag)
%����ͼ��ѹ���������������������·��
%ѹ���������ֵ�����ڽӾ���Ŀ����
m = max(b(:));
%���ڽ�ѹ������ͼ�ľ����ʾ
A = compresstable2matrix(b, Tag);
node_num = 0;
for i = 1:length(A)
    if isempty(find(A(i,:) == 1)) ~= 1
        node_num = node_num + 1;
    end
end
count = 1;
top = 1;
stack(top) = 1; %����һ���ڵ���ջ
flag = 1; %���ĳ���ڵ��Ƿ���ʹ���
re = [];
% node_num
while top ~= 0 %�ж϶�ջ�Ƿ�Ϊ��
    pre_len = length(stack); %��Ѱ��һ���ڵ�ǰ�Ķ�ջ����
    i = stack(top); %ȡ��ջ���ڵ�
    for j = 1:m
        if A(i,j) == 1 && isempty(find(flag == j,1)) %����ڵ���������û�з��ʹ�
            top = top+1; %��չ��ջ
            stack(top) = j; %�½ڵ���ջ
            flag = [flag j]; %���½ڵ���б��
            re = [re;i j]; %���ߴ�����
            count = count + 1;
            break
        end
    end
    %�����ջ����û�����ӣ���ڵ㿪ʼ��ջ
    if length(stack) == pre_len
        if count == node_num
            break
        end
        if top ~= 1
            re = [re;stack(top) stack(top-1)];
            stack(top) = [];
            top = top-1;
        else
            %             re = [re;stack(top) 1];
            stack(top) = [];
            top = top-1;
        end
    end
end
% count
%% ͼ��ѹ���������ڽӾ����ת������DFS���Ӻ���
function A = compresstable2matrix(b, Tag)
%label�Ǻ�Tagͬά�ȵľ��󣬿��Դﵽ��λ����0�����ܴﵽ��λ����1
[n, ~] = size(b);
[map_x, map_y] = size(Tag);
m = max(b(:));
A = zeros(m,m);
for i = 1:n
    A(b(i,1),b(i,2)) = 1;
    A(b(i,2),b(i,1)) = 1;
end
%% ����Ǿ���ת��Ϊͼ��ѹ������
function b = graph_convert(Tag)
[map_x, map_y] = size(Tag);
b = [];
%����ÿ��ÿ���ҵ���Ԫ������λ�ã������ڵķ���Ԫ��������
for i = 1:map_x
    index = find(Tag(i,:) == 0);
    for j = 1:length(index) - 1
        if ((index(j+1) - index(j) == 1))
            % i��ʾ�����ڵ�������index(j)��ʾ�����ڵ�����
            b = [b;[index(j)+(i-1)*map_y index(j+1)+(i-1)*map_y]];
        else
            continue
        end
    end
end
for i = 1:map_y
    index = find(Tag(:,i) == 0);
    for j = 1:length(index) - 1
        if (index(j+1) - index(j) == 1)
            % i��ʾ�����ڵ�������index(j)��ʾ�����ڵ�����
            b = [b;[i+(index(j)-1)*map_y i+(index(j+1)-1)*map_y]];
        else continue
        end
    end
end
b = sortrows(b, 1);
%% �滮·�����չʾ
function result_display(re, Tag)
[map_x, map_y] = size(Tag);
figure(1)
[xData, yData] = netplot(Tag);

%����դ���ź͵�ͼλ��֮��Ļ������
conversion_matrix = reshape((1:map_x * map_y), map_y, map_x);
conversion_matrix = conversion_matrix';

%ģ������˵��˶�·����ɨ���ĸ�������ɫ��ʾ���ظ���ɨ�ĸ����ú�ɫ��ʾ
xx = size(re, 1);
x_temp = [0 1 1 0];
y_temp = [0 0 1 1];
patch('xData', x_temp, 'yData', y_temp, 'FaceColor', 'b');
pause_time = 0.5; %�������ʣ����Ե���
pause(pause_time)
sign = zeros(map_x, map_y);
sign(1, 1) = 1;
for i = 1:xx
    %    temp1 = re(i, :);
    temp2 = re(i, :);
    [xco, yco] = find(conversion_matrix == temp2(1));
    [xco1, yco1] = find(conversion_matrix == temp2(2));
    x_temp = [0 1 1 0] + xco -1;
    y_temp = [0 0 1 1] + yco -1;
    x1_temp = [0 1 1 0] + xco1 -1;
    y1_temp = [0 0 1 1] + yco1 -1;
    if sign(xco1, yco1) == 0 %��ʾ���������˳������ȥ
        sign(xco1, yco1) = 1;
        patch('xData', x1_temp, 'yData', y1_temp, 'FaceColor', 'b');
        pause(pause_time)
    else %��ʾ���ݹ���
        patch('xData', x1_temp, 'yData', y1_temp, 'FaceColor', 'r');
        pause(pause_time)
    end
end

%% �����ײ���չʾ
function step_num_random = random_display(Tag, node_num)
%�����˴�����ԭ�㿪ʼ��ɨ�������˲����м��书��
%Ĭ����ɨ���������ң����ϣ���������
%������д���Ϊ������������滮·�������д���
step_num_random = 0;
sweep_order = [1 0;0 1;-1 0;0 -1];%�ֱ��ʾ���ң����ϣ���������
figure(2)
[xData, yData] = netplot(Tag);
sign = Tag;
%δ��ɨ������Ϊ��ɫ����ɨ��һ�ε�����Ϊ��ɫ���ظ���ɨ��������Ϊ��ɫ
[map_x, map_y] = size(Tag);
xx = [0 1 1 0];
yy = [0 0 1 1];
patch('xData', xx, 'yData', yy, 'FaceColor', 'b');
pause_time = 0.01;
pause(pause_time)
sign(1, 1) = 1;
index = [1 1];
% for i = 1:max_step
step_num_random = 1;
count = 1;
while count < node_num
    for j = 1:4
        time = ceil(rand * 4);
        dir = sweep_order(time, :);
        if index(1)+dir(1)<1 || index(1)+dir(1)>map_x ||...
                index(2)+dir(2)<1 || index(2)+dir(2)>map_y
            continue
        end
        if Tag(index(1)+dir(1), index(2)+dir(2)) == 1
            continue
        end
        index = index + dir;
        x_temp = [0 1 1 0] +index(1) - 1;
        y_temp = [0 0 1 1] + index(2) - 1;
        if sign(index(1), index(2)) == 0
            patch('xData', x_temp, 'yData', y_temp, 'FaceColor', 'b');
            pause(pause_time)
            sign(index(1), index(2)) = 1;
            step_num_random = step_num_random + 1;
            count = count + 1;
            break
        else
            patch('xData', x_temp, 'yData', y_temp, 'FaceColor', 'r');
            pause(pause_time)
            step_num_random = step_num_random + 1;
            break
        end
    end
end


%% ���Ƶ�ͼ�Լ��ϰ����λ��
function [xData, yData] = netplot(Tag)
[map_x, map_y] = size(Tag);
x = 0:map_x;
y = 0:map_y;
x1 = [x(1) x(end)]';
y1 = [y(1) y(end)]';
%�������������ߵ�����xData,yData
x2 = repmat(x1, 1, length(y)-2);
x3 = repmat(x(2) : x(end-1), 2, 1);
xData = [x2 x3];
y2 = repmat(y1, 1, length(x)-2);
y3 = repmat(y(2):y(end-1), 2, 1);
yData = [y3 y2];
h = line(xData, yData);
box on;
set(h, 'Color', 'k');
%����ϰ����λ�ã��ú�ɫ�����ʾ
[co_x, co_y] = find(Tag == 1);
% [co_x co_y]
for i = 1:length(co_x)
    x = [0 1 1 0] + co_x(i) -1;
    y = [0 0 1 1] + co_y(i) -1;
    patch('xData', x, 'yData', y, 'FaceColor', 'k');
end