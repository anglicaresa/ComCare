		select
			CCB.[Client_ID] 'Client_ID'
			,Org.[Organisation_Name] 'Organisation_Name'
			,CBG.[Description] 'ContractBillingGroup'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.[Client_ID] Order by
						CASE
						WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
						when Org.[Organisation_Name] is null then '2'
						ELSE Org.[Organisation_Name] END ASC
				) 'RN'
		from [dbo].[FB_Client_Contract_Billing] CCB
			left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
			left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
			left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
			left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

		where
		1=1
		and CCB.Client_ID = 10072283