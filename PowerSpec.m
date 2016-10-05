function PowerSpec(shotn)

	%Define constants
    skipLines=1;
    delay=(2e-6)*skipLines;%This is based on the digitization rate of our fast digitizer
	kmax=40000;
    cnum = [8 17 31 41 50 61 70 84 94];
    shotbase=int32(shotn(1,1)/1000)*1000;

    %Loop through Shots
    for n=1:length(shotn)
        if (n!=1)
            shotn(1,n)=shotbase+shotn(1,n);
        endif
        for m=1:length(cnum)
            %Open the file to count the lines, then reopen from the beginning for reading. Skip the first six lines.
            fileName=strcat("PowerSpec",int2str(shotn(1,n)),"-Channel",int2str(cnum(m)),".txt");
            fid=fopen(fileName,'r');
            numRows=2^floor(log2(fskipl(fid,Inf)))/skipLines;
            maxTime=(numRows-1)*delay/skipLines;
            fclose(fid);
            fid=fopen(fileName,'r');
            fskipl(fid,6);

            %Read in the data and find sum
            sum=0;
            array=zeros(numRows,1);
            for i=1:numRows
                temp=fgetl(fid);
                temp=strsplit(temp,"\t");
                array(i,1)=str2double(temp{3});
                sum+=array(i,1);
		if skipLines!=1
                	fskipl(fid,skipLines-1);
		endif
            endfor
            fclose(fid);

            %Make time array
            average=sum/numRows;%%%%%%%%%%%
            t=0:delay:maxTime;
            deltaN=array.-average;%%%%%%%%%%%%%%%


            %Calculate FFT, Power Spectrum, and Write files (can also plot if desired)
            X=fft(deltaN);
            f=1/(2*delay)*linspace(0,1,length(X)/2+1);
            f=f';
            Xplot=X(1:length(X)/2+1);
            PS = real(Xplot.*conj(Xplot));
            avg1 = zeros(length(f),1);
            avg2 = zeros(length(f),1);
            for j=501:83888
                avg1(j) = mean(PS(j-500:j+500));
                if (j>1000)
                    avg2(j) = mean(PS(j-1000:j+1000));
                endif
            endfor
            
            data=horzcat(f,PS,avg1,avg2);
            data=data(1:83889,:);
	    %plot(f,avg2)
