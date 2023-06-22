public class aSiteAuthManager {
	public aSiteAuthManager() {
	}

	public static SiteUser__c UserLogin(String us, String pass) {
		SiteUser__c[] users = aSiteUtils.queryResults2(
			SiteUser__c.SObjectType,
			null,
			'Password__c = :v1',
			pass,
			'Email__c = :v2',
			us
		);
		if (users.size() > 0)
			return users[0];
		else
			return null;
	}

	public static Account getActiveAccount_byUser2(SiteUser__c user) {
		SiteUserAccount__c usacc = aSiteAuthManager.VerifyActiveAccount(user);
		Account[] accs = aSiteUtils.queryResults1(Account.SObjectType, null, 'Id = :v1', usacc.Account__c);
		if (accs.size() > 0)
			return accs[0];
		else
			return null;
	}

	public static Account getActiveAccount_byUser(SiteUser__c user) {
		Id cuentaId;
		List<SiteUserAccount__c> lista = new List<SiteUserAccount__c>();
		String queryPlus;
		queryPlus = 'Account__r.Site, Account__r.AccountNumber, Account__r.Grupo_de_cuentas__c, Account__r.Name, Account__r.Nome_Fantasia__c, Account__r.CodigoSAP__c ';

		lista = aSiteUtils.queryResults1(SiteUserAccount__c.SObjectType, queryPlus, 'SiteUser__c = :v1', user.Id);
		for (SiteUserAccount__c userAcc : lista) {
			if (userAcc.Active__c)
				//cuentaId = userAcc.Account__c;
				return userAcc.Account__r;
		}

		//Account[] accs = aSiteUtils.queryResults1(Account.SObjectType, null, 'Id = :v1', cuentaId);
		//if(accs.size() > 0)
		//    return accs[0];
		// else
		return null;
	}

	public static List<SiteUserAccount__c> getUserAccounts_byUser(SiteUser__c user) {
		String queryPlus;
		queryPlus = 'Account__r.Site, Account__r.AccountNumber, Account__r.Grupo_de_cuentas__c, Account__r.Name, Account__r.Nome_Fantasia__c, Account__r.CodigoSAP__c ';

		List<SiteUserAccount__c> lista = new List<SiteUserAccount__c>();
		SiteUserAccount__c[] lusers = aSiteUtils.queryResults1(
			SiteUserAccount__c.SObjectType,
			queryPlus,
			'SiteUser__c = :v1',
			user.Id
		);

		return lusers;
	}

	public static SiteUserAccount__c VerifyActiveAccount(SiteUser__c user) {
		try {
			List<SiteUserAccount__c> lista = new List<SiteUserAccount__c>();
			lista = aSiteAuthManager.getUserAccounts_byUser(user);
			for (SiteUserAccount__c acc : lista) {
				if (acc.Active__c)
					return acc;
			}
			return null;
		} catch (Exception ex) {
			return null;
		}
	}

	public static SiteUserSession__c getUserSession(String token) {
		try {
			//SiteUserSession__c userSess = new SiteUserSession__c();
			String plus = ', SiteUser__r.Email__c, SiteUser__r.Password__c, SiteUser__r.Site__c, SiteUser__r.Address__c, SiteUser__r.Occupation__c, SiteUser__r.Name ';
			String query =
				aSiteUtils.querySelect(SiteUserSession__c.SObjectType) +
				plus +
				' from SiteUserSession__c where Id = :token and valid_session__c = true order by LastModifiedDate desc limit 1';

			SiteUserSession__c[] ss = Database.query(query);
			system.debug('JERE::: getUserSes 1 (' + token + ')');

			if (ss.size() > 0)
				return ss[0];
			else
				return null;
		} catch (Exception ex) {
			return null;
		}
	}

	public static SiteUser__c VerifyUserSession(String token) {
		try {
			SiteUserSession__c userSess = getUserSession(token);
			system.debug('JERE::: VerifyUserSes 1 ' + token);
			if (userSess == null)
				return null;
			system.debug('JERE::: VerifyUserSes 2 ' + userSess);
			SiteUser__c user = new SiteUser__c(Name = userSess.SiteUser__r.Name);
			user.Email__c = userSess.SiteUser__r.Email__c;
			user.Password__c = userSess.SiteUser__r.Password__c;
			user.Site__c = userSess.SiteUser__r.Site__c;
			user.Address__c = userSess.SiteUser__r.Address__c;
			user.Occupation__c = userSess.SiteUser__r.Occupation__c;
			user.Id = userSess.SiteUser__c;

			return user;
		} catch (Exception ex) {
			return null;
		}
	}

	public static String OpenUserSession(String userId, String ip, String company) {
		try {
			String campa_prod = '19/2019';
			String camp_ant = '18/2018';
			String camp_sales = '18/2018';
			Configuracion_USA__c[] confs = aSiteUtils.queryResults1(Configuracion_USA__c.SObjectType, null, 'Id <> :v1', '');
			if (confs.size() > 0) {
				campa_prod = confs[0].Production_Season__c;
				camp_ant = confs[0].Last_Season__c;
				camp_sales = confs[0].Sales_Season__c;
			}

			SiteUserSession__c s = new SiteUserSession__c();
			//buscar si vale la pena traer una session valida
			s.SiteUser__c = userId;
			if (company == null)
				company = 'GDM';
			s.Safra__c = camp_sales; //trae la campaña de los reportes de vta
			s.Production_season__c = campa_prod;
			s.Last_season__c = camp_ant;
			s.Action_Log__c = 'Login, ';
			s.Sales_season__c = camp_sales;
			s.Marca__c = company;
			s.IP__c = ip;
			insert s;
			return s.Id;
		} catch (Exception ex) {
			return null;
		}
	}

	public static String RefreshUserSessionLog(String token, String action) {
		try {
			SiteUserSession__c userSess = getUserSession(token);
			if (userSess == null)
				return null;

			userSess.Action_Log__c = userSess.Action_Log__c + action;
			update userSess;

			return userSess.Id;
		} catch (Exception ex) {
			return null;
		}
	}

	public static String RefreshUserSession(String token) {
		try {
			SiteUserSession__c userSess = getUserSession(token);
			if (userSess == null)
				return null;

			update userSess;

			return userSess.Id;
		} catch (Exception ex) {
			return null;
		}
	}

	public static String CloseUserSession(String token) {
		try {
			SiteUserSession__c userSess = new SiteUserSession__c();
			//SiteUserSession__c[] ss = [Select Id, Close_Time__c From SiteUserSession__c where Id = :token limit 1];
			SiteUserSession__c[] ss = aSiteUtils.queryResults1(SiteUserSession__c.SObjectType, null, 'Id = :v1', token);
			if (ss.size() > 0)
				userSess = ss[0];
			else
				return 'No active session. Token=' + token;

			userSess.Close_Time__c = system.now();
			update userSess;
			return 'Ok';
		} catch (Exception ex) {
			return ex.getMessage();
		}
	}

	public static boolean ForgotPassword(String us, String company) {
		SiteUser__c user;

		SiteUser__c[] users = aSiteUtils.queryResults1(SiteUser__c.SObjectType, null, 'Email__c = :v1', us);

		if (users.size() > 0)
			user = users[0];
		else
			return false;

		try {
			user.Password__c = '123456';
			user.Cadastro_pela_primeira_vez__c = false;
			user.Has_reset_password__c = true;
			user.Reset_by_company__c = company;
			update user;
		} catch (Exception ex) {
			return false;
		}

		return true;
	}

	public static String ChangePassword(String token, String newPassword, String verifyNewPassword, String oldpassword) {
		SiteUser__c us = VerifyUserSession(token);
		system.debug('JERE::: ChangePass 1 ' + token);
		if (us == null)
			return ' No Verify';

		if (us.Password__c == null)
			return 'No password';

		if (us.Password__c != oldpassword)
			return 'No Equal';

		try {
			us.Password__c = newPassword;
			us.Cadastro_pela_primeira_vez__c = true;
			update us;
		} catch (Exception ex) {
			return ex.getMessage();
		}

		return 'Ok';
	}
}