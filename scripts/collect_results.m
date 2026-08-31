input = cell(length(discharges),1);
output = cell(length(discharges),1);
analysed = cell(length(discharges),1);
additional = cell(length(discharges),1);

for i_d = 1:length(discharges)
    runpath = fullfile('results',subfolder,...
        strcat(strrep(discharges{i_d},' ','_'),'_flux'));
    files = dir(runpath);
    foldernames = {files([files.isdir]).name};
    foldernames = foldernames(contains(foldernames,'run_Pfit'));
    foldernum = cell2mat(cellfun(@(s) str2num(s(9:end)),foldernames,'UniformOutput',false));
    [~,i] = max(foldernum);
    foldername = strcat('run_pfit',num2str(foldernum(i)));
    input{i_d} = load(fullfile(runpath,foldername,'Input.mat'));
    output{i_d} = load(fullfile(runpath,foldername,'Output.mat'));
    analysed{i_d} = load(fullfile(runpath,foldername,'Analysed.mat'));
    additional{i_d} = load(fullfile(runpath,foldername,'Additional.mat'));
end

%%

t = cell(length(discharges),1);

Teh = cell(length(discharges),1);
Tec = cell(length(discharges),1);
nec = cell(length(discharges),1);
neh = cell(length(discharges),1);

nCu = cell(length(discharges),1);
nCu_i = cell(length(discharges),1);
nAr = cell(length(discharges),1);
nAr_i = cell(length(discharges),1);

I_tot = cell(length(discharges),1);
I_Cui = cell(length(discharges),1);

rar = cell(length(discharges),1);

arizrate = cell(length(discharges),1);
cuizrate = cell(length(discharges),1);

alpha = cell(length(discharges),1);
alpha_Fb = cell(length(discharges),1);

fluxes = cell(length(discharges),1);
tot_fluxes = cell(length(discharges),1);
fluxes_rt = cell(length(discharges),1);

for i_d = 1:length(discharges)
    t{i_d} = output{i_d}.t/1e-6;
    
    Teh{i_d} = output{i_d}.T_eh;
    Tec{i_d} = output{i_d}.n(:,end);
    nec{i_d} = output{i_d}.n(:,1);
    nec{i_d}(nec{i_d}<1.) = 1.;
    neh{i_d} = output{i_d}.n(:,2);
    neh{i_d}(neh{i_d}<1.) = 1.;
        
    nCu{i_d}    = sum(output{i_d}.n(:,10:15),2);
    nCu_i{i_d}  = sum(output{i_d}.n(:,14:15),2);
    nAr{i_d}    = sum(output{i_d}.n(:,3:9),2);
    nAr_i{i_d}  = sum(output{i_d}.n(:,[3,4,5,8,9]),2);
    rar{i_d}    = sum(output{i_d}.n(:,[3,4,5,8,9]),2);
    rea = input{i_d}.Rea.reactions;
    Ariz = zeros(1,length(rea));
    Cuiz = zeros(1,length(rea));
    
    I_tot{i_d} = sum(output{i_d}.I,2) + sum(output{i_d}.I_se,2);
    I_Cui{i_d} = output{i_d}.I(:,s.Cui);

    for i=1:length(rea)
        if ( sum(contains(rea(i).Prod,'Ari'))+sum(contains(rea(i).Prod,'Arii'))...
            -sum(contains(rea(i).React,'Ari'))-sum(contains(rea(i).React,'Arii')) )>0
            Ariz(i) = 1;
        end
        if ( sum(contains(rea(i).Prod,'Cui'))+sum(contains(rea(i).Prod,'Cuii'))...
            -sum(contains(rea(i).React,'Cui'))-sum(contains(rea(i).React,'Cuii')) )>0
            Cuiz(i) = 1;
        end
    end
    arizrate{i_d} = sum(output{i_d}.Rate(:,logical(Ariz)),2);
    cuizrate{i_d} = sum(output{i_d}.Rate(:,logical(Cuiz)),2);
    
    alpha{i_d} = additional{i_d}.alpha_R_t_all;
    alpha_Fb{i_d} = additional{i_d}.alpha_F_flux_t;
    alpha_Fb{i_d}(end) = 0.;
    
    s = input{i_d}.s;
    Para = input{i_d}.Para;
    Spe = input{i_d}.Spe;
    species = fieldnames(s);
    
    fluxes{i_d} = output{i_d}.Diffrate*Para.V_IR/Para.S_BP;
    fluxes{i_d}(:,s.Ari) = output{i_d}.GAMMA_ion_BP(:,s.Ari);
    fluxes{i_d}(:,s.Arii) = output{i_d}.GAMMA_ion_BP(:,s.Arii);
    fluxes{i_d}(:,s.Cui) = output{i_d}.GAMMA_ion_BP(:,s.Cui);
    fluxes{i_d}(:,s.Cuii) = output{i_d}.GAMMA_ion_BP(:,s.Cuii);
  
    fluxes_rt{i_d} = output{i_d}.I;
    
    for j=1:size(fluxes{i_d},2)
        tot_fluxes{i_d}(j) = trapz(output{i_d}.t,fluxes{i_d}(:,j));
    end
end

% ionization rate summary

irate = struct();
lbls = {'I','II','III','A','B','C'};
for i_d=1:length(discharges)

    irate(i_d).lbl = lbls{i_d};
    irate(i_d).nAr0 = output{i_d}.n(1,s.Ar);
    irate(i_d).p_Ariz = trapz(t{i_d},arizrate{i_d})/irate(i_d).nAr0*1e-6;

%     irate(i_d).nAr0 = output{i_d}.n(1,s.Ar);
%     irate(i_d).max_rAriz = max(arizrate{id});
%     irate(i_d).max_proba = irate(i_d).max_rAriz/irate(i_d).nAr0;
end
irate = struct2table(irate);

% rarefaction summary

rarf = struct();
lbls = {'I','II','III','A','B','C'};
for i_d=1:length(discharges)
  
    [v, i] = min(rar{i_d});
    rarf(i_d).lbl = lbls{i_d};
    rarf(i_d).n0 = rar{i_d}(1);
    rarf(i_d).t = t{i_d}(i);
    
    rarf(i_d).n = v;
    
    rarf(i_d).n_Ar = output{i_d}.n(i,s.Ar);
    rarf(i_d).n_Arm3P0 = output{i_d}.n(i,s.Arm3P0);
    rarf(i_d).n_Arm3P2 = output{i_d}.n(i,s.Arm3P2);
    rarf(i_d).n_Ari = output{i_d}.n(i,s.Ari);
    rarf(i_d).n_Arii = output{i_d}.n(i,s.Arii);
    rarf(i_d).n_ArW = output{i_d}.n(i,s.ArW);
    rarf(i_d).n_ArH = output{i_d}.n(i,s.ArH);
    
    rarf(i_d).r = v/rar{i_d}(1);
    
    rarf(i_d).r_Ar = rarf(i_d).n_Ar/rarf(i_d).n0;
    rarf(i_d).r_Arm3P0 = rarf(i_d).n_Arm3P0/rarf(i_d).n0;
    rarf(i_d).r_Arm3P2 = rarf(i_d).n_Arm3P2/rarf(i_d).n0;
    rarf(i_d).r_Ari = rarf(i_d).n_Ari/rarf(i_d).n0;
    rarf(i_d).r_Arii = rarf(i_d).n_Arii/rarf(i_d).n0;
    rarf(i_d).r_ArW = rarf(i_d).n_ArW/rarf(i_d).n0;
    rarf(i_d).r_ArH = rarf(i_d).n_ArH/rarf(i_d).n0;
end
rarf = struct2table(rarf);

% total densities summary
toden = struct();
lbls = {'I','II','III','A','B','C'};
for i_d=1:length(discharges)

end
toden = struct2table(toden);

% total flux summary
toflu = struct();
for i_d=1:length(discharges)

end
toflu = struct2table(toflu);

% total fluxes summary

tfluxes = struct();
for i_d=1:length(discharges)
    tfluxes(i_d).lbl = lbls{i_d};
    for i=1:length(species)
        tfluxes(i_d).(species{i}) = tot_fluxes{i_d}(i);
    end
%     Spe = input{i_d}.Spe;
%     tfluxes(i_d).Ar_refill = (Para.S_BP/Para.V_IR)*h_ran*v_ran(Spe.T(s.Ar),Spe.M(s.Ar))*(n(s.Ar)-Spe.ID(s.Ar));
end
tfluxes = struct2table(tfluxes);

% Cui fraction is different from F_flux. It turns out, F_flux is only
% calculated for the duration of the pulse. This doesn't make sense when
% constraining it with the experimental ionized flux fraction which should
% also include ions from after the pulse.

tfluxes.Cu_tot = tfluxes.Cu + tfluxes.Cum1 + tfluxes.Cum2 + tfluxes.Cum3 + tfluxes.Cui + tfluxes.Cuii;
tfluxes.f_Cu = tfluxes.Cu./tfluxes.Cu_tot;
tfluxes.f_Cum1 = tfluxes.Cum1./tfluxes.Cu_tot;
tfluxes.f_Cum2 = tfluxes.Cum2./tfluxes.Cu_tot;
tfluxes.f_Cum3 = tfluxes.Cum3./tfluxes.Cu_tot;
tfluxes.f_Cui = tfluxes.Cui./tfluxes.Cu_tot;
tfluxes.f_Cuii = tfluxes.Cuii./tfluxes.Cu_tot;

% fractions for Ar don't make much sense because of refill. Nevertheless
% the toal flux should be positive, which isn't the case and has me a bit
% worried.

tfluxes.Ar_tot = tfluxes.Ar + tfluxes.Arm3P0 + tfluxes.Arm3P2 + tfluxes.ArW + tfluxes.ArH + tfluxes.Ari + tfluxes.Arii;
tfluxes.f_Ar = tfluxes.Ar./tfluxes.Ar_tot;
tfluxes.f_Arm3P0 = tfluxes.Arm3P0./tfluxes.Ar_tot;
tfluxes.f_Arm3P2 = tfluxes.Arm3P2./tfluxes.Ar_tot;
tfluxes.f_ArW = tfluxes.ArW./tfluxes.Ar_tot;
tfluxes.f_ArH = tfluxes.ArH./tfluxes.Ar_tot;
tfluxes.f_Ari = tfluxes.Ari./tfluxes.Ar_tot;
tfluxes.f_Arii = tfluxes.Arii./tfluxes.Ar_tot;

% current contribution summary

icontrib = struct();
for i_d=1:length(discharges)
    icontrib(i_d).lbl = lbls{i_d};
    
    I_se = sum(output{i_d}.I_se,2);
    I = sum(output{i_d}.I,2) + I_se;
    [v, i] = max(I);
    
    icontrib(i_d).t_pk = t{i_d}(i);
    
    icontrib(i_d).I_tot_pk = v;
    
    icontrib(i_d).I_se_pk = I_se(i);
    icontrib(i_d).I_Cui_pk = output{i_d}.I(i,s.Cui);
    icontrib(i_d).I_Cuii_pk = output{i_d}.I(i,s.Cuii);
    icontrib(i_d).I_Ari_pk = output{i_d}.I(i,s.Ari);
    icontrib(i_d).I_Arii_pk = output{i_d}.I(i,s.Arii);
    
    icontrib(i_d).f_se_pk = icontrib(i_d).I_se_pk/icontrib(i_d).I_tot_pk;
    icontrib(i_d).f_Cui_pk = icontrib(i_d).I_Cui_pk/icontrib(i_d).I_tot_pk;
    icontrib(i_d).f_Cuii_pk = icontrib(i_d).I_Cuii_pk/icontrib(i_d).I_tot_pk;
    icontrib(i_d).f_Ari_pk = icontrib(i_d).I_Ari_pk/icontrib(i_d).I_tot_pk;
    icontrib(i_d).f_Arii_pk = icontrib(i_d).I_Arii_pk/icontrib(i_d).I_tot_pk;
    
    icontrib(i_d).I_tot_tot = trapz(output{i_d}.t,I);

    icontrib(i_d).I_se_tot = trapz(output{i_d}.t,I_se);
    icontrib(i_d).I_Cui_tot = trapz(output{i_d}.t,output{i_d}.I(:,s.Cui));
    icontrib(i_d).I_Cuii_tot = trapz(output{i_d}.t,output{i_d}.I(:,s.Cuii));
    icontrib(i_d).I_Ari_tot = trapz(output{i_d}.t,output{i_d}.I(:,s.Ari));
    icontrib(i_d).I_Arii_tot = trapz(output{i_d}.t,output{i_d}.I(:,s.Arii));
    
    icontrib(i_d).f_se_tot = icontrib(i_d).I_se_tot/icontrib(i_d).I_tot_tot;
    icontrib(i_d).f_Cui_tot = icontrib(i_d).I_Cui_tot/icontrib(i_d).I_tot_tot;
    icontrib(i_d).f_Cuii_tot = icontrib(i_d).I_Cuii_tot/icontrib(i_d).I_tot_tot;
    icontrib(i_d).f_Ari_tot = icontrib(i_d).I_Ari_tot/icontrib(i_d).I_tot_tot;
    icontrib(i_d).f_Arii_tot = icontrib(i_d).I_Arii_tot/icontrib(i_d).I_tot_tot;
end
icontrib = struct2table(icontrib);

% pk densites summary

pkdens = struct();
for i_d=1:length(discharges)
    pkdens(i_d).lbl = lbls{i_d};
    
    I_se = sum(output{i_d}.I_se,2);
    I = sum(output{i_d}.I,2) + I_se;
    [v, i] = max(I);
    
    pkdens(i_d).t_pk = t{i_d}(i);
    
    for i=1:length(species)
        pkdens(i_d).(strcat('n_',species{i},'_pk')) = output{i_d}.n(i,s.(species{i}));
    end
    n_Cu_tot_pk = 0;
    n_Ar_tot_pk = 0;
    for i=1:length(species)
        if contains(species{i},'Cu')
            n_Cu_tot_pk = n_Cu_tot_pk + pkdens(i_d).(strcat('n_',species{i},'_pk'));
        elseif contains(species{i},'Ar')
            n_Ar_tot_pk = n_Ar_tot_pk + pkdens(i_d).(strcat('n_',species{i},'_pk'));
        end
    end
    pkdens(i_d).n_Cu_tot_pk = n_Cu_tot_pk;
    pkdens(i_d).n_Ar_tot_pk = n_Ar_tot_pk;
    % Cu
    for i=1:length(species)
        if contains(species{i},'Cu')
            pkdens(i_d).(strcat('f_',species{i},'_pk')) =  pkdens(i_d).(strcat('n_',species{i},'_pk'))/pkdens(i_d).n_Cu_tot_pk;
        end
    end
    % Ar
    for i=1:length(species)
        if contains(species{i},'Ar')
            pkdens(i_d).(strcat('f_',species{i},'_pk')) =  pkdens(i_d).(strcat('n_',species{i},'_pk'))/pkdens(i_d).n_Ar_tot_pk;
        end
    end
    pkdens(i_d).T_ec = output{i_d}.n(i,end);
    pkdens(i_d).T_eh = output{i_d}.T_eh(i);
end
pkdens = struct2table(pkdens);

% save summaries

% save(fullfile('results',subfolder,'rf'),'rarf','tfluxes','icontrib','pkdens','irate');

%% PLOTS
c = colororder();
util.fig.setDefaultStyle();

t_Armin = 0;
for i_d = 1:length(discharges)
    i20us = find(t{i_d}>=20,1,'first');
    [~,i_minAri] = min(output{i_d}.n(1:i20us,s.Ari));
    if t{i_d}(i_minAri) > t_Armin
        t_Armin = t{i_d}(i_minAri);
    end
end

linestyles = {'-','--','-.',':'};

lbls = {'I','II','III','IV','V','VI'};

xlbl = '$t$ [$\mu$s]';

hist = 1:3;
new = 4:6;
both = 1:6;

lsts = {hist,new,both};
nms = {'hist','new','both'};

% %% Ar ionization rate
% 
% type = 'ar iz proba';
% ylbl = '$R_{\rm Ar,iz}/n_{\rm Ar,0}$ [$\%$]';
% lbl = '';
% lgndloc = 'south';
% lgndor = 'horizontal';
% x = @(i) t{i};
% y = @(i) arizrate{i}/output{i}.n(1,s.Ar)*100;
% x_lim = [0,150];
% y_lim = [0,100];
% 
% for j=1:3
%     fh = figure('Name',strcat(type,'_',nms{j}));
%     hold all; i_style = 1;
%     for i=lsts{j}
%         if i_style > length(linestyles); i_style=1; end
%         plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
%         i_style = i_style + 1;
%     end
%     xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
%     if ~isempty(lbl)
%         text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
%     end
%     if ~isempty(lgndloc)
%         legend(lbls{lsts{j}});
%         fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
%         fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
%     end
% end

%% Rarefaction

type = 'rarefaction';
ylbl = '$n_{\rm Ar}/n_{\rm Ar,0}$ [$\%$]';
lbl = '';
lgndloc = 'south';
lgndor = 'horizontal';
x = @(i) t{i};
y = @(i) rar{i}(:)/rar{i}(1)*100;
x_lim = [0,150];
y_lim = [0,100];

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

% %% Ionization probability
% 
% type = 'alpha';
% ylbl = '$\alpha_{\rm t}(t)$ [$\%$]';
% lbl = '';
% lgndloc = 'northeast';
% lgndor = 'horizontal';
% x = @(i) t{i}(1:length(alpha_Fb{i}));
% y = @(i) 100*alpha_Fb{i};
% x_lim = [0,100];
% y_lim = [0,100];
% 
% for j=1:3
%     fh = figure('Name',strcat(type,'_',nms{j}));
%     hold all; i_style = 1;
%     for i=lsts{j}
%         if i_style > length(linestyles); i_style=1; end
%         plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
%         i_style = i_style + 1;
%     end
%     xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
%     if ~isempty(lbl)
%         text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
%     end
%     if ~isempty(lgndloc)
%         legend(lbls{lsts{j}});
%         fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
%         fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
%     end
% end

%% density fraction

type = 'density fraction';
ylbl = '$\Sigma n_{\rm Cu}/\Sigma n_{\rm Ar}$ [$\%$]';
lbl = '';
lgndloc = 'north';
lgndor = 'horizontal';
x = @(i) t{i};
y = @(i) nCu{i}(:)./nAr{i}*100;
x_lim = [0,150];
y_lim = [0,250];

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% degree of ionization

type = 'degree of ionization';
ylbl = '$n_{\rm e}/(n_n+n_i)$ [$\%$]';
lbl = '';
lgndloc = 'north';
lgndor = 'horizontal';
x = @(i) t{i};
y = @(i) (nec{i}+neh{i})./(nCu{i}+nAr{i})*100;
x_lim = [0,150];
y_lim = [0,50];

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% current contribution

type = 'ion current fraction';
ylbl = '$I_{\rm Cu^{+1}}/I$ [$\%$]';
lbl = '';
lgndloc = 'south';
lgndor = 'horizontal';
x = @(i) t{i};
y = @(i) I_Cui{i}./(I_tot{i}+1e-6)*100;
x_lim = [0,150];
y_lim = [0,100];

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% ion flux fraction BP

type = 'ion flux fraction bp';
ylbl = '$\Gamma_{\rm Cu^{+1},BP}/\Sigma \Gamma_{\rm i,BP}$ [$\%$]';
lbl = '';
lgndloc = 'south';
lgndor = 'horizontal';
x = @(i) t{i};
y = @(i) fluxes{i}(:,s.Cui)./sum(fluxes{i}(:,[s.Cui,s.Ari,s.Cuii,s.Arii]),2)*100;
x_lim = [0,150];
y_lim = [0,100];

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% e density cold

type = 'e density cold';
ylbl = '$n_{\rm e,cold}$ [m$^{-3}$]';
lbl = '(a)';
lgndloc = 'south';
lgndor = 'horizontal';
x_lim = [0,100];
y_lim = [1e+17,1e+20];
x = @(i) t{i};
y = @(i) nec{i};

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    set(gca,'YScale','log');
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% e temperature cold

type = 'e temperature cold';
%ylbl = '$k_{\rm B}\,T_{\rm e,cold}$ [eV]';
ylbl = '$T_{\rm e,cold}$ [eV]';
lbl = '(b)';
lgndloc = '';
lgndor = 'horizontal';
x_lim = [0,100];
y_lim = [0,35];
x = @(i) t{i};
y = @(i) Tec{i};

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% e density hot

type = 'e density hot';
ylbl = '$n_{\rm e,hot}$ [m$^{-3}$]';
lbl = '(a)';
lgndloc = 'south';
lgndor = 'horizontal';
x_lim = [0,100];
y_lim = [1e+13,1e+17];
x = @(i) t{i};
y = @(i) neh{i};

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    set(gca,'YScale','log');
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% e temperature hot

type = 'e temperature hot';
%ylbl = '$k_{\rm B}\,T_{\rm e,hot}$ [eV]';
ylbl = '$T_{\rm e,hot}$ [eV]';
lbl = '(b)';
lgndloc = '';
lgndor = 'horizontal';
x_lim = [0,100];
y_lim = [0,350];
x = @(i) t{i};
y = @(i) Teh{i};

for j=1:3
    fh = figure('Name',strcat(type,'_',nms{j}));
    hold all; i_style = 1;
    for i=lsts{j}
        if i_style > length(linestyles); i_style=1; end
        plot(x(i),y(i),'Color',c(i,:),'LineStyle',linestyles{i_style});
        i_style = i_style + 1;
    end
    xlabel(xlbl); ylabel(ylbl); xlim(x_lim); ylim(y_lim);
    if ~isempty(lbl)
        text(0.90,0.925,lbl,'Units','normalized','Color',0*[1,1,1]);
    end
    if ~isempty(lgndloc)
        legend(lbls{lsts{j}});
        fh.CurrentAxes.Legend.FontSize = 14; fh.CurrentAxes.Legend.Box = 'on';
        fh.CurrentAxes.Legend.Location = lgndloc; fh.CurrentAxes.Legend.Orientation = lgndor;
    end
end

%% format and save plots

% fhs = findall(0, 'Type', 'figure');
% for i = 1:numel(fhs)
%     fh.CurrentAxes.Legend.FontSize = 14;
%     fh.CurrentAxes.Legend.Location = 'northeast';
%     fh.CurrentAxes.Legend.Box = 'on';
% end

%util.save_open_figs('',subfolder,{'png','eps'},true);
%util.cofb({''});