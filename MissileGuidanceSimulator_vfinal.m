function MissileGuidanceSimulator()

clc;

S.dt   = 0.01;
S.tMax = 80;
S.t    = 0;
S.stp  = 0;
S.run  = false;
S.pau  = false;
S.hit  = false;
S.kr   = 20;
S.aMax = 80*9.81;

S.m0 = [-5000; -3000];
S.t0 = [0; 0];

S.N    = 4;
S.mspd = 450;
S.tspd = 200;
S.glaw = 'Proportional Navigation';
S.tmot = 'Straight';
S.cam  = 'Follow';
S.lam  = 0;
S.ld   = 0;
S.vc   = 0;
S.dst  = inf;
S.acl  = 0;
S.mnd  = inf;

S.mxh = [];  S.myh = [];
S.txh = [];  S.tyh = [];

fig = figure('Name','Missile Guidance Simulator', ...
    'NumberTitle','off', ...
    'Color',[0.015 0.025 0.045], ...
    'MenuBar','none','ToolBar','none', ...
    'Units','pixels','Position',[60 60 1380 820], ...
    'CloseRequestFcn',@onClose);

% axes bottom raised to 0.20 so xlabel is not clipped by control strip
ax = axes('Parent',fig, ...
    'Units','normalized','Position',[0.03 0.20 0.62 0.77], ...
    'Color',[0.004 0.010 0.022], ...
    'XColor',[0.50 0.72 0.88],'YColor',[0.50 0.72 0.88], ...
    'GridColor',[0.10 0.20 0.34],'GridAlpha',0.6, ...
    'FontName','Consolas','FontSize',9,'Box','on');
hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
xlabel(ax,'Downrange X (m)','Color',[0.72 0.88 1.00],'FontName','Consolas');
ylabel(ax,'Crossrange Y (m)','Color',[0.72 0.88 1.00],'FontName','Consolas');
title(ax,'2D MISSILE GUIDANCE ENGAGEMENT', ...
    'Color',[0.88 0.96 1.00],'FontName','Consolas','FontWeight','bold','FontSize',11);


hmt = plot(ax,nan,nan,'-','Color',[1.00 0.70 0.10],'LineWidth',2.0);
htt = plot(ax,nan,nan,'-','Color',[0.00 0.88 1.00],'LineWidth',2.0);
hls = plot(ax,nan,nan,'--','Color',[0.55 0.72 0.95],'LineWidth',0.9);
hmv = plot(ax,nan,nan,'-','Color',[1.00 0.88 0.30],'LineWidth',1.5,'HandleVisibility','off');
htv = plot(ax,nan,nan,'-','Color',[0.25 1.00 1.00],'LineWidth',1.5,'HandleVisibility','off');
hav = plot(ax,nan,nan,'-','Color',[1.00 0.22 0.18],'LineWidth',1.8,'HandleVisibility','off');
hkr = plot(ax,nan,nan,'-','Color',[0.85 0.16 0.10],'LineWidth',0.9,'HandleVisibility','off');
hmk = plot(ax,nan,nan,'^','MarkerSize',10, ...
    'MarkerFaceColor',[1.00 0.54 0.05],'MarkerEdgeColor',[1.00 0.94 0.30], ...
    'LineWidth',1.5,'HandleVisibility','off');
htk = plot(ax,nan,nan,'o','MarkerSize',9, ...
    'MarkerFaceColor',[0.00 0.84 1.00],'MarkerEdgeColor',[0.75 1.00 1.00], ...
    'LineWidth',1.5,'HandleVisibility','off');
hst = text(ax,0,0,'','Color',[0.38 1.00 0.38],'FontName','Consolas', ...
    'FontWeight','bold','FontSize',13,'HorizontalAlignment','center','Visible','off');

legend(ax,[hmt,htt,hls],{'Missile','Target','LOS'}, ...
    'TextColor',[0.80 0.92 1.00],'Color',[0.02 0.04 0.09], ...
    'EdgeColor',[0.14 0.28 0.48],'FontName','Consolas','FontSize',8,'Location','northwest');

hp = uipanel('Parent',fig,'Units','normalized','Position',[0.668 0.16 0.322 0.81], ...
    'BackgroundColor',[0.012 0.020 0.042], ...
    'ForegroundColor',[0.80 0.92 1.00], ...
    'HighlightColor',[0.30 0.16 0.72], ...
    'Title','  ENGAGEMENT HUD','FontName','Consolas','FontWeight','bold','FontSize',9);

hax = axes('Parent',hp,'Units','normalized','Position',[0 0 1 1], ...
    'Color','none','XColor','none','YColor','none','XLim',[0 1],'YLim',[0 1]);
hold(hax,'on');

lbs = {'MSL SPEED   (m/s)','TGT SPEED   (m/s)','CLOSING VEL (m/s)', ...
       'LOS ANGLE     (deg)','LOS RATE   (rad/s)','CMD ACCEL  (m/s^2)', ...
       'RANGE            (m)','TIME              (s)','ETA               (s)','NAV CONST'};
yy = linspace(0.96,0.52,numel(lbs));
hv = gobjects(numel(lbs),1);
for k = 1:numel(lbs)
    text(hax,0.04,yy(k),lbs{k},'Color',[0.46 0.68 0.82],'FontName','Consolas','FontSize',8);
    hv(k) = text(hax,0.97,yy(k),'---','Color',[1.00 0.74 0.14], ...
        'FontName','Consolas','FontSize',8.5,'FontWeight','bold','HorizontalAlignment','right');
end

plot(hax,[0.04 0.96],[0.49 0.49],'-','Color',[0.20 0.32 0.52],'LineWidth',0.8);
text(hax,0.50,0.45,'GUIDANCE LAW','Color',[0.46 0.68 0.82], ...
    'FontName','Consolas','FontSize',8,'HorizontalAlignment','center');
hgl = text(hax,0.50,0.41,'PROPORTIONAL NAVIGATION','Color',[0.38 1.00 0.58], ...
    'FontName','Consolas','FontSize',8.5,'FontWeight','bold','HorizontalAlignment','center');
text(hax,0.50,0.37,'a_n = N * Vc * lambda_dot','Color',[0.60 0.60 0.88], ...
    'FontName','Consolas','FontSize',7.5,'HorizontalAlignment','center','Interpreter','none');

htx = uicontrol('Parent',hp,'Style','text', ...
    'Units','normalized','Position',[0.03 0.01 0.94 0.32], ...
    'BackgroundColor',[0.008 0.014 0.028],'ForegroundColor',[0.78 0.92 1.00], ...
    'HorizontalAlignment','left','FontName','Consolas','FontSize',8,'String','');

cb = uipanel('Parent',fig,'Units','normalized','Position',[0.00 0.00 1.00 0.145], ...
    'BackgroundColor',[0.018 0.028 0.050],'ForegroundColor',[0.80 0.92 1.00], ...
    'HighlightColor',[0.30 0.16 0.72], ...
    'Title','  SIMULATION CONTROLS','FontName','Consolas','FontWeight','bold','FontSize',8);

    function sl = mksl(lbl, tag, x0, mn, mx, df)
        uicontrol('Parent',cb,'Style','text','Units','normalized', ...
            'Position',[x0 0.70 0.10 0.22],'String',lbl, ...
            'BackgroundColor',[0.018 0.028 0.050],'ForegroundColor',[0.78 0.92 1.00], ...
            'HorizontalAlignment','center','FontName','Consolas','FontSize',7.5);
        vt = uicontrol('Parent',cb,'Style','text', ...
            'Units','normalized','Position',[x0 0.06 0.10 0.22], ...
            'String',sprintf('%.1f',df), ...
            'BackgroundColor',[0.018 0.028 0.050],'ForegroundColor',[1.00 0.74 0.14], ...
            'HorizontalAlignment','center','FontName','Consolas','FontSize',8,'FontWeight','bold');
        sl = uicontrol('Parent',cb,'Style','slider', ...
            'Units','normalized','Position',[x0 0.34 0.10 0.30], ...
            'Min',mn,'Max',mx,'Value',df,'BackgroundColor',[0.08 0.14 0.24]);
        sl.Callback = @(src,~) set(vt,'String',sprintf('%.1f',src.Value));
    end

sN  = mksl('Nav Const N',   'sN',   0.01,  2,    8,    4);
sms = mksl('MSL Spd (m/s)', 'sms',  0.13, 200, 2700,  450);
sts = mksl('TGT Spd (m/s)', 'sts',  0.25,  50, 1100,  200);

    function dd = mkdd(lbl, x0, w, items)
        uicontrol('Parent',cb,'Style','text','Units','normalized', ...
            'Position',[x0 0.70 w 0.22],'String',lbl, ...
            'BackgroundColor',[0.018 0.028 0.050],'ForegroundColor',[0.78 0.92 1.00], ...
            'HorizontalAlignment','center','FontName','Consolas','FontSize',7.5);
        dd = uicontrol('Parent',cb,'Style','popupmenu','Units','normalized', ...
            'Position',[x0 0.30 w 0.36],'String',items,'Value',1, ...
            'FontName','Consolas','FontSize',8, ...
            'BackgroundColor',[0.06 0.12 0.22],'ForegroundColor',[0.80 0.92 1.00]);
    end

dg = mkdd('Guidance Law', 0.38, 0.11, {'Proportional Navigation','Pure Pursuit','Lead Pursuit'});
dt = mkdd('Target Motion',0.51, 0.11, {'Straight','Weave','Constant Turn','Evasive'});
dc = mkdd('Camera',       0.64, 0.09, {'Follow','Global','Chase'});

bw = 0.07;  bh = 0.72;  by = 0.12;
bs = uicontrol('Parent',cb,'Style','pushbutton','Units','normalized', ...
    'Position',[0.75 by bw bh],'String','START', ...
    'FontName','Consolas','FontWeight','bold','FontSize',10, ...
    'BackgroundColor',[0.04 0.36 0.10],'ForegroundColor',[0.60 1.00 0.60], ...
    'Callback',@onStart);
bp = uicontrol('Parent',cb,'Style','pushbutton','Units','normalized', ...
    'Position',[0.83 by bw bh],'String','PAUSE', ...
    'FontName','Consolas','FontWeight','bold','FontSize',10, ...
    'BackgroundColor',[0.26 0.20 0.04],'ForegroundColor',[1.00 0.88 0.40], ...
    'Callback',@onPause);
br = uicontrol('Parent',cb,'Style','pushbutton','Units','normalized', ...
    'Position',[0.91 by bw bh],'String','RESET', ...
    'FontName','Consolas','FontWeight','bold','FontSize',10, ...
    'BackgroundColor',[0.28 0.06 0.04],'ForegroundColor',[1.00 0.65 0.45], ...
    'Callback',@onReset);

doReset();

    function onStart(~,~)
        if S.run, return; end
        S.run = true;  S.pau = false;
        set(bp,'String','PAUSE');
        mainLoop();
    end

    function onPause(~,~)
        S.pau = ~S.pau;
        if S.pau, set(bp,'String','RESUME');
        else,     set(bp,'String','PAUSE'); end
    end

    function onReset(~,~)
        S.run = false;
        pause(0.05);
        doReset();
    end

    function onClose(~,~)
        S.run = false;
        delete(fig);
    end

    function doReset()
        S.run = false;  S.pau = false;  S.hit = false;
        S.t   = 0;      S.stp = 0;
        S.mnd = inf;    S.dst = inf;
        S.lam = 0;      S.ld  = 0;
        S.vc  = 0;      S.acl = 0;

        rdctl();

        S.tgt.p0  = S.t0;
        S.tgt.pos = S.t0;
        S.tgt.hdg = 0;
        S.tgt.vel = S.tspd * [1;0];

        S.msl.pos = S.m0;
        ang = atan2(S.t0(2)-S.m0(2), S.t0(1)-S.m0(1));
        S.msl.vel = S.mspd * [cos(ang);sin(ang)];
        S.msl.acc = [0;0];

        S.mxh = S.msl.pos(1);  S.myh = S.msl.pos(2);
        S.txh = S.tgt.pos(1);  S.tyh = S.tgt.pos(2);

        set(hst,'Visible','off');
        set(bp,'String','PAUSE');
        draw();  telem();  drawnow;
    end

    function rdctl()
        % read directly from handles — no findobj, no search overhead
        S.N    = sN.Value;
        S.mspd = sms.Value;
        S.tspd = sts.Value;

        gl = dg.String;  S.glaw = gl{dg.Value};
        tl = dt.String;  S.tmot = tl{dt.Value};
        cl = dc.String;  S.cam  = cl{dc.Value};

        if ishandle(hgl)
            set(hgl,'String',upper(S.glaw));
        end
    end

    function mainLoop()
        while S.run && ishandle(fig) && S.t < S.tMax
            if S.pau, drawnow; pause(0.03); continue; end

            rdctl();
            stepTgt();
            stepGuid();
            stepMsl();

            S.t   = S.t   + S.dt;
            S.stp = S.stp + 1;

            S.mxh(end+1) = S.msl.pos(1);
            S.myh(end+1) = S.msl.pos(2);
            S.txh(end+1) = S.tgt.pos(1);
            S.tyh(end+1) = S.tgt.pos(2);

            rv    = S.tgt.pos - S.msl.pos;
            S.dst = norm(rv);
            S.mnd = min(S.mnd, S.dst);

            if S.dst < S.kr
                S.hit = true;  S.run = false;
                draw(); telem();
                mid = 0.5*(S.msl.pos + S.tgt.pos);
                % offset banner upward so it clears the trajectory lines
                off = diff(ylim(ax)) * 0.12;
                set(hst,'String', ...
                    sprintf('TARGET INTERCEPTED   t = %.2f s   miss distance = %.1f m',S.t,S.mnd), ...
                    'Color',[0.38 1.00 0.38],'Position',[mid(1), mid(2)+off],'Visible','on');
                drawnow;  return;
            end

            if mod(S.stp,3) == 0
                draw(); telem(); drawnow limitrate;
            end
        end

        if ~S.hit && ishandle(fig)
            S.run = false;
            mid = 0.5*(S.msl.pos + S.tgt.pos);
            off = diff(ylim(ax)) * 0.12;
            set(hst,'String','SIMULATION TIMEOUT  --  MISS', ...
                'Color',[1.00 0.32 0.18],'Position',[mid(1), mid(2)+off],'Visible','on');
            telem(); drawnow;
        end
    end

    function stepTgt()
        v = S.tspd;
        switch S.tmot
            case 'Straight'
                S.tgt.vel = v * [1;0];
                S.tgt.pos = S.tgt.pos + S.tgt.vel * S.dt;
            case 'Weave'
                x = S.tgt.p0(1) + v*S.t;
                y = S.tgt.p0(2) + 650*sin(0.55*S.t);
                S.tgt.pos = [x;y];
                S.tgt.vel = [v; 650*0.55*cos(0.55*S.t)];
            case 'Constant Turn'
                S.tgt.hdg = S.tgt.hdg + 3*(pi/180)*S.dt;
                S.tgt.vel = v*[cos(S.tgt.hdg); sin(S.tgt.hdg)];
                S.tgt.pos = S.tgt.pos + S.tgt.vel*S.dt;
            case 'Evasive'
                tr = (5.5*pi/180)*sin(0.8*S.t) + (2.0*pi/180)*sin(2.0*S.t);
                S.tgt.hdg = S.tgt.hdg + tr*S.dt;
                S.tgt.vel = v*[cos(S.tgt.hdg); sin(S.tgt.hdg)];
                S.tgt.pos = S.tgt.pos + S.tgt.vel*S.dt;
        end
    end

    function stepGuid()
        rv = S.tgt.pos - S.msl.pos;
        vv = S.tgt.vel - S.msl.vel;
        R  = max(norm(rv),1e-6);
        Vm = max(norm(S.msl.vel),1e-6);

        S.lam = atan2(rv(2),rv(1));
        S.ld  = (rv(1)*vv(2) - rv(2)*vv(1)) / R^2;
        S.vc  = -dot(rv,vv)/R;

        vh = S.msl.vel/Vm;
        nh = [-vh(2); vh(1)];

        switch S.glaw
            case 'Proportional Navigation'
                S.msl.acc = (S.N * S.vc * S.ld) * nh;
            case 'Pure Pursuit'
                e = sang(vh, rv/R);
                S.msl.acc = (3.0*Vm*e) * nh;
            case 'Lead Pursuit'
                lt  = min(max(R/max(Vm,1),0.2),8.0);
                aim = (S.tgt.pos + S.tgt.vel*lt) - S.msl.pos;
                aim = aim/max(norm(aim),1e-6);
                e   = sang(vh,aim);
                S.msl.acc = (4.0*Vm*e) * nh;
        end

        an = norm(S.msl.acc);
        if an > S.aMax
            S.msl.acc = S.msl.acc*(S.aMax/an);
        end
        S.acl = norm(S.msl.acc);
    end

    function stepMsl()
        S.msl.vel = S.msl.vel + S.msl.acc*S.dt;
        vm = norm(S.msl.vel);
        if vm > 1e-6
            S.msl.vel = S.mspd * S.msl.vel/vm;
        end
        S.msl.pos = S.msl.pos + S.msl.vel*S.dt;
    end

    function draw()
        set(hmt,'XData',S.mxh,'YData',S.myh);
        set(htt,'XData',S.txh,'YData',S.tyh);
        set(hls,'XData',[S.msl.pos(1) S.tgt.pos(1)], ...
                'YData',[S.msl.pos(2) S.tgt.pos(2)]);
        set(hmk,'XData',S.msl.pos(1),'YData',S.msl.pos(2));
        set(htk,'XData',S.tgt.pos(1),'YData',S.tgt.pos(2));
        vec(hmv, S.msl.pos, S.msl.vel, 2.0);
        vec(htv, S.tgt.pos, S.tgt.vel, 2.0);
        vec(hav, S.msl.pos, S.msl.acc, 0.15);
        th2 = linspace(0,2*pi,120);
        set(hkr,'XData',S.tgt.pos(1)+S.kr*cos(th2), ...
                'YData',S.tgt.pos(2)+S.kr*sin(th2));
        camUpdate();
    end

    function vec(h, o, v, sc)
        L = norm(v);
        if L < 1e-6, set(h,'XData',nan,'YData',nan); return; end
        ep = o + (v/L)*min(700,L*sc);
        set(h,'XData',[o(1) ep(1)],'YData',[o(2) ep(2)]);
    end

    function camUpdate()
        switch S.cam
            case 'Follow'
                mid = 0.5*(S.msl.pos+S.tgt.pos);
                rng = max(1400,min(8000,0.75*norm(S.msl.pos-S.tgt.pos)+900));
                xlim(ax,mid(1)+[-rng rng]);
                ylim(ax,mid(2)+[-0.65*rng 0.65*rng]);
            case 'Global'
                ax2=[S.mxh S.txh]; ay2=[S.myh S.tyh];
                if numel(ax2)<2, return; end
                xlim(ax,[min(ax2)-800 max(ax2)+800]);
                ylim(ax,[min(ay2)-800 max(ay2)+800]);
            case 'Chase'
                xlim(ax,S.msl.pos(1)+[-1700 1700]);
                ylim(ax,S.msl.pos(2)+[-1700 1700]);
        end
    end

    function telem()
        vm  = norm(S.msl.vel);
        vt  = norm(S.tgt.vel);
        eta = 999.99;
        if S.vc > 1e-4, eta = min(S.dst/S.vc,999.99); end

        vs = {sprintf('%.1f',vm), sprintf('%.1f',vt), sprintf('%.1f',S.vc), ...
              sprintf('%.2f',S.lam*180/pi), sprintf('%.4f',S.ld), ...
              sprintf('%.2f',S.acl), sprintf('%.0f',S.dst), ...
              sprintf('%.2f',S.t), sprintf('%.2f',eta), sprintf('%.2f',S.N)};
        for k=1:numel(vs), set(hv(k),'String',vs{k}); end
        if S.vc>0, set(hv(3),'Color',[0.38 1.00 0.38]);
        else,      set(hv(3),'Color',[1.00 0.32 0.20]); end

        if S.hit,         st='TARGET INTERCEPTED';
        elseif S.pau,     st='PAUSED';
        elseif S.run,     st='ACTIVE';
        elseif S.t==0,    st='READY';
        else,             st='STOPPED'; end

        set(htx,'String',sprintf( ...
            'STATUS    : %s\nTime      : %8.2f s\nGuidance  : %s\nTarget    : %s\n\nMin miss  : %8.1f m\nLOS angle : %8.2f deg\nLOS rate  : %8.4f rad/s\nAccel cmd : %8.1f m/s^2\nAccel cmd : %8.2f g\n', ...
            st,S.t,S.glaw,S.tmot,S.mnd,S.lam*180/pi,S.ld,S.acl,S.acl/9.81));
    end

    function a = sang(u,v)
        u=u/max(norm(u),1e-6); v=v/max(norm(v),1e-6);
        a=atan2(u(1)*v(2)-u(2)*v(1),dot(u,v));
    end

end