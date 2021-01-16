BEGIN

	-- variable declaration
	DECLARE @ComparerPath VARCHAR(100)
	DECLARE @BackupPath VARCHAR(100)
	DECLARE @logPath VARCHAR(100)


	-- first server and database. used to be production server
	DECLARE @svr1_svr VARCHAR(100)
	DECLARE @svr1_svrpath VARCHAR(100)
	DECLARE @svr1_db VARCHAR(100)
	DECLARE @svr1_alias VARCHAR(100)
	DECLARE @svr1_linked VARCHAR(100)

	-- second server. develop or testing server
	DECLARE @svr2_svr VARCHAR(100)
	DECLARE @svr2_svrpath VARCHAR(100)
	DECLARE @svr2_db VARCHAR(100)
	DECLARE @svr2_alias VARCHAR(100)
	DECLARE @svr2_linked VARCHAR(100)

	


	-- BEGIN SCRIPT SETUP --
	
				-- fist database - production
				SET @svr1_svr = 'Server1\instance' --server name or ip from de sql server. use server\instance for non default instance databases
				SET @svr1_db = 'CRONUS_Production' -- database name
				SET @svr1_alias = 'PRODUCTION' -- server alias, only for clarity in this script (is not the server alias in sql server)
				SET @svr1_linked = '' -- if the server is linked with the current server, set the linked name.

				-- second database - develop or testing enviroment
				SET @svr2_svr = 'Server2\instance'
				SET @svr2_db = 'CRONUS_Develop_Env'
				SET @svr2_alias = 'DEVELOP'
				SET @svr2_linked = ''

				--
				SET @ComparerPath = 'D:\Temp\Export' --folder path to export objects to compare. is a temporary directory. don´t end with \
				SET @BackupPath = 'D:\Temp\Objectbackup' --folder path to export objects to backup.. don´t end with \
				SET @logPath = 'D:\Temp' --folder path to save the navisoin exporting log. don´t end with \

				
	--	END SCRIPT SETUP --
	



	-- commands for execute in windows shell

	DECLARE @comands AS TABLE (
		line INT,
		cmdcomparer VARCHAR(MAX) NULL,
		cmdbackupsvr1 VARCHAR(MAX) NULL,
		cmdbackupsvr2 VARCHAR(MAX) NULL
	)
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (0,'','','')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (1,'CLS','CLS','CLS')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (2,'REM @@ObjectTypeName@@ @@ObjectId@@ @@ObjectName@@'
																				 ,'REM @@ObjectTypeName@@ @@ObjectId@@ @@ObjectName@@'
																				 ,'REM @@ObjectTypeName@@ @@ObjectId@@ @@ObjectName@@')

	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (3
								,'finsql.exe command=exportobjects, servername=@@svr1_svr@@ ,database=@@svr1_db@@ ,ntauthentication=1, file=@@ComparerPath@@\@@svr1_svrpath@@_@@svr1_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log.txt'
								,'finsql.exe command=exportobjects, servername=@@svr1_svr@@ ,database=@@svr1_db@@ ,ntauthentication=1, file=@@BackupPath@@\@@svr1_svrpath@@_@@svr1_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log_txt.txt'
								,'finsql.exe command=exportobjects, servername=@@svr2_svr@@ ,database=@@svr2_db@@ ,ntauthentication=1, file=@@BackupPath@@\@@svr2_svrpath@@_@@svr2_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log_fob.txt')

	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (4,'PING 127.0.0.1 -n 5 -w 2000 >NUL','','')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (5
								,'finsql.exe command=exportobjects, servername=@@svr2_svr@@ ,database=@@svr2_db@@ ,ntauthentication=1, file=@@ComparerPath@@\@@svr2_svrpath@@_@@svr2_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log.txt'
								,'finsql.exe command=exportobjects, servername=@@svr1_svr@@ ,database=@@svr1_db@@ ,ntauthentication=1, file=@@BackupPath@@\@@svr1_svrpath@@_@@svr1_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.fob, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log_txt.txt'
								,'finsql.exe command=exportobjects, servername=@@svr2_svr@@ ,database=@@svr2_db@@ ,ntauthentication=1, file=@@BackupPath@@\@@svr2_svrpath@@_@@svr2_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.fob, filter="Type=@@ObjectType@@;ID=@@ObjectId@@", logfile=@@logpath@@\log_fob.txt')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (6,'PING 127.0.0.1 -n 5 -w 2000 >NUL','','')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (7
								,'START /MAX kdiff3.exe @@ComparerPath@@\@@svr1_svrpath@@_@@svr1_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt @@ComparerPath@@\@@svr2_svrpath@@_@@svr2_db@@_@@ObjectTypeName@@_@@ObjectId@@_@@now@@.txt'
								,''
								,'')
	INSERT @comands (line, cmdcomparer,cmdbackupsvr1,cmdbackupsvr2) VALUES (8,'','','')

	


	IF OBJECT_ID('tempdb..#Allobjects') IS NOT NULL
		DROP TABLE #Allobjects

	
	DECLARE @now VARCHAR(50)
	SET @now = CAST(DATEPART(YEAR,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(MONTH,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(DAY,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(HOUR,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(MINUTE,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(SECOND,GETDATE()) AS VARCHAR) + '' +
				 CAST(DATEPART(MILLISECOND,GETDATE()) AS VARCHAR)



	SET @svr1_svrpath = REPLACE(@svr1_svr,'\','_')
	SET @svr2_svrpath = REPLACE(@svr2_svr,'\','_')

	UPDATE @comands
		SET  cmdbackupsvr1 = CONCAT('REM ',@svr1_svr,' ',@svr1_db)
			,cmdbackupsvr2 = CONCAT('REM ',@svr2_svr,' ',@svr2_db)
	WHERE line = 0

	IF OBJECT_ID('tempdb..#obj_SVR1') IS NOT NULL
		DROP TABLE #obj_SVR1
	IF OBJECT_ID('tempdb..#obj_SVR2') IS NOT NULL
		DROP TABLE #obj_SVR2

	CREATE TABLE #obj_SVR1 (
		Svr VARCHAR(50),
		Db VARCHAR(50),
		Alias VARCHAR(50),
		ObjectType INT,
		ObjectId INT,
		CompanyName VARCHAR(100),
		ObjectName VARCHAR(100),
		ObjectDateTime DATETIME,
		VersionList VARCHAR(1000)
	)

	CREATE TABLE  #obj_SVR2 (
		Svr VARCHAR(50),
		Db VARCHAR(50),
		Alias VARCHAR(50),
		ObjectType INT,
		ObjectId INT,
		CompanyName VARCHAR(100),
		ObjectName VARCHAR(100),
		ObjectDateTime DATETIME,
		VersionList VARCHAR(1000)
	)

	DECLARE @cmdextract NVARCHAR(4000)
	DECLARE @svr1_link_path VARCHAR(500)
	DECLARE @svr2_link_path VARCHAR(500)
	IF LTRIM(RTRIM(@svr1_linked)) = '' BEGIN 
		SET @svr1_link_path = ''
	END ELSE BEGIN 
		SET @svr1_link_path = CONCAT('[',@svr1_linked,'].')
	END 
	IF LTRIM(RTRIM(@svr2_linked)) = '' BEGIN 
		SET @svr2_link_path = ''
	END ELSE BEGIN 
		SET @svr2_link_path = CONCAT('[',@svr2_linked,'].')
	END 

	--navision objects from server 1
	SET @cmdextract = '
	INSERT #obj_SVR1 (Svr,Db,Alias,ObjectType,ObjectId,CompanyName,ObjectName,ObjectDateTime,VersionList)
	SELECT 
		''@svr1_svr'',''@svr1_db'',''@svr1_alias''
		,[Type],ID,[Company Name],Name
		,CAST(
			CAST(DATEPART(DAY, [Date]) AS VARCHAR) + ''/'' +
			CAST(DATEPART(MONTH, [Date]) AS VARCHAR) + ''/'' +
			CAST(DATEPART(YEAR, [Date]) AS VARCHAR) + '' '' +
			CAST(DATEPART(HOUR, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(MINUTE, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(SECOND, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(MILLISECOND, [Time]) AS VARCHAR) + '''' 			
		AS DATETIME) AS ObjectDateTime
		,[Version List]
	FROM @linkedserver[@svr1_db].dbo.[Object]'
	SET @cmdextract = REPLACE(@cmdextract,'@svr1_alias',@svr1_alias)
	SET @cmdextract = REPLACE(@cmdextract,'@svr1_db',@svr1_db)
	SET @cmdextract = REPLACE(@cmdextract,'@svr1_svr',@svr1_svr)
	SET @cmdextract = REPLACE(@cmdextract,'@svr1_svr',@svr1_svr)
	SET @cmdextract = REPLACE(@cmdextract,'@linkedserver',@svr1_link_path)

	--PRINT @cmdextract
	EXEC sp_executesql @cmdextract	




	--navision objects from server 2
	SET @cmdextract = '
	INSERT #obj_SVR2 (Svr,Db,Alias,ObjectType,ObjectId,CompanyName,ObjectName,ObjectDateTime,VersionList)
	SELECT 
		''@svr2_svr'',''@svr2_db'',''@svr2_alias''
		,[Type],ID,[Company Name],Name
		,CAST(
			CAST(DATEPART(DAY, [Date]) AS VARCHAR) + ''/'' +
			CAST(DATEPART(MONTH, [Date]) AS VARCHAR) + ''/'' +
			CAST(DATEPART(YEAR, [Date]) AS VARCHAR) + '' '' +
			CAST(DATEPART(HOUR, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(MINUTE, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(SECOND, [Time]) AS VARCHAR) + '':'' +
			CAST(DATEPART(MILLISECOND, [Time]) AS VARCHAR) + '''' 			
		AS DATETIME) AS ObjectDateTime
		,[Version List]
	FROM @linkedserver[@svr2_db].dbo.[Object]'
	SET @cmdextract = REPLACE(@cmdextract,'@svr2_alias',@svr2_alias)
	SET @cmdextract = REPLACE(@cmdextract,'@svr2_db',@svr2_db)
	SET @cmdextract = REPLACE(@cmdextract,'@svr2_svr',@svr2_svr)
	SET @cmdextract = REPLACE(@cmdextract,'@linkedserver',@svr2_link_path)
	
	--PRINT @cmdextract
	EXEC sp_executesql @cmdextract	



	-- save all obects 
	SELECT DISTINCT *
		,CASE
			--TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber
			WHEN Allobjects.ObjectType = 0 THEN 'Table Data'
			WHEN Allobjects.ObjectType = 1 THEN 'Table'
			WHEN Allobjects.ObjectType = 2 THEN ''
			WHEN Allobjects.ObjectType = 3 THEN 'Report'
			WHEN Allobjects.ObjectType = 4 THEN ''
			WHEN Allobjects.ObjectType = 5 THEN 'Codeunit'
			WHEN Allobjects.ObjectType = 6 THEN 'XMLport'
			WHEN Allobjects.ObjectType = 7 THEN 'MenuSuite'
			WHEN Allobjects.ObjectType = 8 THEN 'Page'
			WHEN Allobjects.ObjectType = 9 THEN 'Query'
			WHEN Allobjects.ObjectType = 10 THEN 'System'
			WHEN Allobjects.ObjectType = 11 THEN 'FieldNumber'			
		 END AS ObjectTypeName
	INTO #Allobjects	
	FROM 
	(
		--objects form server 1
		SELECT objsvr1.ObjectType,objsvr1.ObjectId,CompanyName,ObjectName 
		FROM #obj_SVR1 objsvr1 

		UNION ALL

		--objects form server 2
		SELECT objsvr2.ObjectType,objsvr2.ObjectId,CompanyName,ObjectName 
		FROM #obj_SVR2 objsvr2 


	) Allobjects




		/*
				Result 1
				Objets that only exist in one of the servers.
		*/		

		SELECT 
		'New objects' AS Result,
		allob.ObjectTypeName,allob.ObjectId,allob.ObjectName,allob.ObjectType
		,svr_1.ObjectId svr_1
		,svr_2.ObjectId svr_2
		,CASE 
			WHEN svr_1.ObjectId IS NULL AND svr_2.ObjectId IS NOT NULL THEN @svr2_svr + ' - ' + @svr2_alias
			WHEN svr_1.ObjectId IS NOT NULL AND svr_2.ObjectId IS NULL THEN @svr1_svr + ' - ' + @svr1_alias
			ELSE 'ERROR' 
			END AS NewInServer

		FROM #Allobjects allob
			LEFT OUTER JOIN #obj_SVR1 svr_1 ON svr_1.ObjectType = allob.ObjectType AND svr_1.CompanyName = allob.CompanyName AND svr_1.ObjectId = allob.ObjectId
			LEFT OUTER JOIN #obj_SVR2 svr_2 ON svr_2.ObjectType = allob.ObjectType AND svr_2.CompanyName = allob.CompanyName AND svr_2.ObjectId = allob.ObjectId

		WHERE 
			(svr_1.ObjectType IS NULL AND svr_1.CompanyName IS NULL AND svr_1.ObjectId IS NULL)
			OR 
			(svr_2.ObjectType IS NULL AND svr_2.CompanyName IS NULL AND svr_2.ObjectId IS NULL)

		ORDER BY allob.ObjectTypeName,allob.ObjectId




		/*
				Result 2
				Objects with diferences bewteen databases. 
		*/	
		DECLARE @Diferencesresult AS TABLE (
			Result VARCHAR(100),
			ObjectTypeName VARCHAR(100),
			ObjectId BIGINT,
			ObjectName VARCHAR(100),
			ObjectType INT,
			NewerIn VARCHAR(100),
			SVR1_Date_Time DATETIME,
			SVR2_Date_Time DATETIME,
			SVR1_VersionList VARCHAR(1000),
			SVR2_VersionList VARCHAR(1000)
		)

		INSERT @Diferencesresult
		(
			Result,
			ObjectTypeName,
			ObjectId,
			ObjectName,
			ObjectType,
			NewerIn,
			SVR1_Date_Time,
			SVR2_Date_Time,
			SVR1_VersionList,
			SVR2_VersionList
		)
		SELECT 
			'Objetcts with diferences' AS Result,
			allob.ObjectTypeName,allob.ObjectId,allob.ObjectName,allob.ObjectType
			,CASE 
			WHEN svr_1.ObjectDateTime > svr_2.ObjectDateTime THEN  @svr1_alias -- + ' - ' + @svr1_svr 
			WHEN svr_1.ObjectDateTime < svr_2.ObjectDateTime THEN @svr2_alias -- + ' - ' + @svr2_svr
			WHEN svr_1.ObjectDateTime = svr_2.ObjectDateTime THEN '  NAME | VERSION LIST  '
			END AS NewerIn
			,svr_1.ObjectDateTime AS SVR1_Date_Time
			,svr_2.ObjectDateTime AS SVR2_Date_Time
			,svr_1.VersionList AS SVR1_VersionList
			,svr_2.VersionList AS SVR2_VersionList

		FROM #Allobjects allob
		LEFT OUTER JOIN #obj_SVR1 svr_1 ON svr_1.ObjectType = allob.ObjectType AND svr_1.CompanyName = allob.CompanyName AND svr_1.ObjectId = allob.ObjectId
		LEFT OUTER JOIN #obj_SVR2 svr_2 ON svr_2.ObjectType = allob.ObjectType AND svr_2.CompanyName = allob.CompanyName AND svr_2.ObjectId = allob.ObjectId
		WHERE 1=1
				AND allob.ObjectType NOT IN (0)	
				AND(
				svr_1.ObjectDateTime <> svr_2.ObjectDateTime 
				OR svr_1.VersionList <> svr_2.VersionList		
				OR svr_1.ObjectName <> svr_2.ObjectName )
		ORDER BY allob.ObjectType,allob.ObjectId

		-- show the objects with diferences
		SELECT *
		FROM @Diferencesresult result
		WHERE 1=1 -- add some filter here
		ORDER BY result.ObjectType,result.ObjectId



			

		--generate commands for compare with Kdiff, backup object in fob and txt from  both servers
		SET @now = FORMAT(GETDATE(),'yyyyMMddHHmmss')	
		SELECT 'Commands' AS Result,result.ObjectTypeName,	result.ObjectId		,result.ObjectName	,c.line Line
		   ,REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(c.cmdcomparer,'@@ObjectTypeName@@',ObjectTypeName)
				   ,'@@ObjectId@@',result.ObjectId)
				   ,'@@ObjectName@@',result.ObjectName)
				   ,'@@ObjectType@@',result.ObjectType)
				   ,'@@svr1_svr@@',@svr1_svr)
				   ,'@@svr2_svr@@',@svr2_svr)
				   ,'@@svr1_svrpath@@',REPLACE(@svr1_svrpath,'\','_'))
				   ,'@@svr1_db@@',REPLACE(@svr1_db,'\','_'))
				   ,'@@now@@',@now)
				   ,'@@ComparerPath@@',@ComparerPath)
				   ,'@@svr2_svrpath@@',REPLACE(@svr2_svrpath,'\','_') )
				   ,'@@svr2_db@@',REPLACE(@svr2_db,'\','_'))
				   ,'@@BackupPath@@',@BackupPath)
				   ,'@@logpath@@',@logPath)
				AS Comparison_Commands

		   ,REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(c.cmdbackupsvr1,'@@ObjectTypeName@@',ObjectTypeName)
				   ,'@@ObjectId@@',result.ObjectId)
				   ,'@@ObjectName@@',result.ObjectName)
				   ,'@@ObjectType@@',result.ObjectType)
				   ,'@@svr1_svr@@',@svr1_svr)
				   ,'@@svr2_svr@@',@svr2_svr)
				   ,'@@svr1_svrpath@@',REPLACE(@svr1_svrpath,'\','_'))
				   ,'@@svr1_db@@',REPLACE(@svr1_db,'\','_'))
				   ,'@@now@@',@now)
				   ,'@@ComparerPath@@',@ComparerPath)
				   ,'@@svr2_svrpath@@',REPLACE(@svr2_svrpath,'\','_') )
				   ,'@@svr2_db@@',REPLACE(@svr2_db,'\','_'))
				   ,'@@BackupPath@@',@BackupPath)
				   ,'@@logpath@@',@logPath)
				AS Backup_SVR_1_Commands

		   ,REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(c.cmdbackupsvr2,'@@ObjectTypeName@@',ObjectTypeName)
				   ,'@@ObjectId@@',result.ObjectId)
				   ,'@@ObjectName@@',result.ObjectName)
				   ,'@@ObjectType@@',result.ObjectType)
				   ,'@@svr1_svr@@',@svr1_svr)
				   ,'@@svr2_svr@@',@svr2_svr)
				   ,'@@svr1_svrpath@@',REPLACE(@svr1_svrpath,'\','_'))
				   ,'@@svr1_db@@',REPLACE(@svr1_db,'\','_'))
				   ,'@@now@@',@now)
				   ,'@@ComparerPath@@',@ComparerPath)
				   ,'@@svr2_svrpath@@',REPLACE(@svr2_svrpath,'\','_') )
				   ,'@@svr2_db@@',REPLACE(@svr2_db,'\','_'))
				   ,'@@BackupPath@@',@BackupPath)
				   ,'@@logpath@@',@logPath)
				AS Backup_SVR_2_Commands

		FROM @Diferencesresult result
			JOIN @comands c ON 1=1
		WHERE 1=1 -- add some filter here
		ORDER BY result.ObjectType,result.ObjectId,c.line
			

		

	






























	IF OBJECT_ID('tempdb..#Allobjects') IS NOT NULL
		DROP TABLE #Allobjects
	IF OBJECT_ID('tempdb..#obj_SVR1') IS NOT NULL
		DROP TABLE #obj_SVR1
	IF OBJECT_ID('tempdb..#obj_SVR2') IS NOT NULL
		DROP TABLE #obj_SVR2
END