#ifndef MAIN_H
#define MAIN_H

#include <stdint.h>
#include "server.h"

class CConfig
{
public:
	bool m_Verbose;
	char m_aConfigFile[1024];
	char m_aWebDir[1024];
	char m_aTemplateFile[1024];
	char m_aJSONFile[1024];
	char m_aBindAddr[256];
	int m_Port;

	CConfig();
};

class CMain
{
	CConfig m_Config;
	CServer m_Server;

	struct CClient
	{
		bool m_Active;
		bool m_Disabled;
		bool m_Connected;
		int m_ClientNetID;
		int m_ClientNetType;
		char m_aServerid[128];
		char m_aNameserver[128];
		char m_aHostname[128];
		char m_aLocation[128];
		char m_aUsername[128];
		char m_aPassword[128];
		char m_aCustom[512];

		int64 m_TimeConnected;
		int64 m_LastUpdate;

		struct Cstatus
		{
			bool m_Status4;
			bool m_Status6;
			int64_t m_Uptime;
			double m_Load;
			int64_t m_NetworkRx;
			int64_t m_NetworkTx;
			int64_t m_MemTotal;
			int64_t m_MemUsed;
			int64_t m_SwapTotal;
			int64_t m_SwapUsed;
			int64_t m_HDDTotal;
			int64_t m_HDDUsed;
			double m_CPU;
			int64_t m_SSHD_Service;
			int64_t m_Stunnel4_Service;
			int64_t m_OpenVPN_Service;
			int64_t m_Dropbear_Service;
			int64_t m_Squid3_Service;
			int64_t m_BadVPN_Service;
			// Options
			bool m_Pong;
		} m_status;
	} m_aClients[NET_MAX_CLIENTS];

	struct CJSONUpdateThreadData
	{
		CClient *pClients;
		CConfig *pConfig;
		volatile short m_ReloadRequired;
	} m_JSONUpdateThreadData;

	static void JSONUpdateThread(void *pUser);

public:
	CMain(CConfig Config);

	void OnNewClient(int ClienNettID, int ClientID);
	void OnDelClient(int ClientNetID);
	int HandleMessage(int ClientNetID, char *pMessage);
	int ReadConfig();
	int Run();

	CClient *Client(int ClientID) { return &m_aClients[ClientID]; }
	CClient *ClientNet(int ClientNetID);
	const CConfig *Config() const { return &m_Config; }
	int ClientNetToClient(int ClientNetID);
};

#endif
