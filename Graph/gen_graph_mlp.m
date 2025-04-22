% classname={
% "BasketballDunk",
% "BasketballSport",
% "Biking",
% "CliffDiving",
% "CricketBowling",
% "Diving",
% "Fencing",
% "FloorGymnastics",
% "GolfSwing",
% "HorseRiding",
% "IceDancing",
% "LongJump",
% "PoleVault",
% "RopeClimbing",
% "SalsaSpin",
% "SkateBoarding",
% "Skiing",
% "Skijet",
% "SoccerJuggling",
% "Surfing",
% "TennisSwing",
% "TrampolineJumping",
% "VolleyballSpiking",
% "WalkingWithDog"
% };

classname={
    "stip1",
    "stip2",
    "stip3",
    "stip4",
    "stip5"
};
% 
P={};
W={};
V={};
y=[];
gamma=0.5;
count=0;
% load num_videos_train.txt
load /home/sravani/code_stl_new/train.txt
for c=1:5
    for v=1:train(c,2)
        count=count+1;
        %F=load(strcat(classname{c},'/',classname{c},'_',num2str(v),'_feat_scores.csv'));
        if exist(strcat('/home/sravani/stip_code/data/stip_files/features1/scores/train/',classname{c},'/',classname{c},'_',num2str(v),'_','feat','.csv'),'file') ~= 2
            count=count-1;
            continue
        end
        F=load(strcat('/home/sravani/stip_code/data/stip_files/features1/scores/train/',classname{c},'/',classname{c},'_',num2str(v),'_','feat','.csv'));
        nd=size(F,1);
        if nd==0
            count=count-1;
            continue;
        end
        idx=randperm(nd,nd);
        F=F(idx,:);
        if nd>1000
            F=F(1:1000,:);
        end
        X=F(:,1:162);
        P{count}=F(:,163:165);
        s=F(:,166);
        n=size(X,1);
        X=X./repmat(sqrt(sum(X.*X,2)),1,162);
        L=repmat(sum(X.*X,2),1,n);
        L=L+L';
        L=L-2*(X*X');
        L(L<0)=0;
        K=exp(-gamma*sqrt(L));
        L=repmat(sum(P{count}.*P{count},2),1,n);
        L=L+L';
        L=L-2*(P{count}*P{count}');
        L(L<0)=0;
        W{count}=K./sqrt(L);
        W{count}(W{count}==Inf)=0;
        V{count}=s;
        y(count,1)=c;
        disp([c,v,count]);
    end
end
save('/home/sravani/stip_code/data/stip_files/features1/train1_merl.mat','P','W','V','y','-v7.3');



P1={};
W1={};
V1={};
y1=[];
%ious = {};
gamma=0.5;
count=0;
%load num_videos_test.txt
load /home/sravani/code_stl_new/test.txt
for c=1:5
    for v=test(c,1):test(c,2)
        count=count+1;
%         F=load(strcat(classname{c},'/',classname{c},'_',num2str(v),'_feat_scores.csv'));
%         F=load(strcat('test/pruned_features/',classname{c},'/',num2str(v),'.csv'));
        if exist(strcat('/home/sravani/stip_code/data/stip_files/features1/scores/test/',classname{c},'/',classname{c},'_',num2str(v),'_','feat','.csv'),'file') ~= 2
            count=count-1;
            continue
        end
        F=load(strcat('/home/sravani/stip_code/data/stip_files/features1/scores/test/',classname{c},'/',classname{c},'_',num2str(v),'_','feat','.csv'));
        nd=size(F,1);
        if nd==0
            count=count-1;
            continue;
        end
        %iou=load(strcat('test/',classname{c},'/iou_',num2str(v),'.csv'));
        %ious{count}=iou(:,1);
        
        idx=randperm(nd,nd);
        F=F(idx,:);
        if nd>1000
            F=F(1:1000,:);
        end
        X=F(:,1:162);
        P1{count}=F(:,163:165);
        s=F(:,166);
        n=size(X,1);
        X=X./repmat(sqrt(sum(X.*X,2)),1,162);
        L=repmat(sum(X.*X,2),1,n);
        L=L+L';
        L=L-2*(X*X');
        L(L<0)=0;
        K=exp(-gamma*sqrt(L));
        L=repmat(sum(P1{count}.*P1{count},2),1,n);
        L=L+L';
        L=L-2*(P1{count}*P1{count}');
        L(L<0)=0;
        W1{count}=K./sqrt(L);
        W1{count}(W1{count}==Inf)=0;
        V1{count}=s;
        y1(count,1)=c;
        disp([c,v,count]);
    end
end
%ious = cell2mat(ious);
%ious = ious';
save('/home/sravani/stip_code/data/stip_files/features1/test1_merl.mat','P1','W1','V1','y1','-v7.3');


v=10;
Px=P1{v};
Wx=W1{v};
A=double(Wx>(mean(Wx(:))+0*std(Wx(:))));
plot3(Px(:,1),Px(:,3),Px(:,2),'r*');hold on;
for i=1:size(A,1)
    for j=1:size(A,1)
        if(A(i,j))
            plot3([Px(i,1);Px(j,1)],[Px(i,3);Px(j,3)],[Px(i,2);Px(j,2)],'g');hold on;
        end
    end
end

ntrain=size(y,1);
ntest=size(y1,1);
for v=1:ntrain
   G(v).am=double(W{v}>(mean(W{v}(:))+1*std(W{v}(:))));
   G(v).nl.values = round(V{v}*100);
   k=0;
   for j=1:size(G(v).am,1)
       G(v).al{j,1}=[find(G(v).am(j,:))];
   end
   disp(v);
end

for v=1:size(y1,1)
   G(ntrain+v).am=double(W1{v}>(mean(W1{v}(:))+1*std(W1{v}(:))));
   G(ntrain+v).nl.values = round(V1{v}*100);
   k=0;
   for j=1:size(G(ntrain+v).am,1)
       G(ntrain+v).al{j,1}=[find(G(ntrain+v).am(j,:))];
   end
   disp(v);
end

addpath(genpath('/home/sravani/stip_code/data/stip_files/features1/graph_kernels'));
[K,runtime] = WL(G,10,1)
Kn=normalizekm(K{11});

 
% system("ml");
#system("python3 /home/dinesh/precomputed_SVM.py");



% [w,pc]=pca([X;Xt]);
% pc1=pc(ntrain+1:ntrain+ntest,:);
% pc(ntrain+1:ntrain+ntest,:)=[];
% 
% for c=1:10
%     %subplot(3,4,c);
%     plot(pc(y==c,1),pc(y==c,2),'.');hold on;
%     plot(pc1(y1==c,1),pc1(y1==c,2),'x');hold on;
% end
% 
% Xtrain=zeros(87*87,ntrain);
% Xtest=zeros(87*87,ntest);
% for i=1:ntrain
%     Xtrain(:,i)=reshape(W{i},87*87,1);
% end
% for i=1:ntest
%     Xtest(:,i)=reshape(W1{i},87*87,1);
% end
% 
% for i=1:1097
%     csvwrite(strcat("~/graph_w/W",num2str(i),".csv"),W{i});
% end
% for i=1:266
%     csvwrite(strcat("~/graph_w/Wt",num2str(i),".csv"),W1{i});
% end
