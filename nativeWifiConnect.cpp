/******************************/
/** by: DENG GUANGY YONG    ***/
/**      2020/9/27			***/
/******************************/

#include "nativeWifiConnect.h"

// Need to link with Wlanapi.lib and Ole32.lib
#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "ole32.lib")

NativeWifiConnect::NativeWifiConnect()
{
	connectInfoSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);
	opCode = wlan_opcode_value_type_invalid;
	STR_NAME = "wifiName";
	STR_PASSWORD = "password";
	STR_PROFILE_DEMO =
		"<?xml version=\"1.0\"?> \
<WLANProfile xmlns=\"http://www.microsoft.com/networking/WLAN/profile/v1\">\
    <name>wifiName</name>\
    <SSIDConfig>\
        <SSID>\
            <name>wifiName</name>\
        </SSID>\
    </SSIDConfig>\
    <connectionType>ESS</connectionType>\
    <connectionMode>auto</connectionMode>\
    <MSM>\
        <security>\
            <authEncryption>\
                <authentication>WPAPSK</authentication>\
                <encryption>TKIP</encryption>\
                <useOneX>false</useOneX>\
            </authEncryption>\
            <sharedKey>\
                <keyType>passPhrase</keyType>\
                <protected>false</protected>\
                <keyMaterial>password</keyMaterial>\
            </sharedKey>\
        </security>\
    </MSM>\
</WLANProfile>";
}

NativeWifiConnect::~NativeWifiConnect()
{
	if (pConnectInfo != NULL) {
		WlanFreeMemory(pConnectInfo);
		pConnectInfo = NULL;
	}
	if (pInterfaceList != NULL)
	{
		WlanFreeMemory(pInterfaceList);
		pInterfaceList = NULL;
	}
}

bool NativeWifiConnect::openWLAN(std::map<std::string, int>& wlanMap)
{
	DWORD dwNegotiatedVersion;
	/*phClientHandle: �ͻ����ڴ˻Ự��ʹ�õľ�����˾���������Ự������������ʹ�á�*/
	dwResult = WlanOpenHandle(1, nullptr, &dwNegotiatedVersion, &hClientHandle);
	if (dwResult != ERROR_SUCCESS)
	{
		WlanCloseHandle(hClientHandle, nullptr);
		return false;
	}
	/*���� WlanScan����������ɨ�衣Ȼ��Ӧ�ó���Ӧ�ȴ���
	4 wlan_notification_acm_scan_complete�յ�֪ͨ��ʱ��
	Ȼ��Ӧ�ó�����Ե���WlanGetNetworkBsList��WlanGetAbleNetworkList����
	��������������������б��˹��̿��Զ����ظ���Ӧ�ó�����Ը��ٶԿ�����������ĸ���
	*/
	if (!refreshWLAN(wlanMap))
		return false;
	return true;
}

bool NativeWifiConnect::connectWLAN(const std::string wlanName)
{
	wchar_t *wName = stringToWideChar(wlanName);
	WLAN_CONNECTION_PARAMETERS wlanConnPara;
	wlanConnPara.wlanConnectionMode = wlan_connection_mode_profile;
	//    wlan_connection_mode_profile	��ʹ�������ļ��������ӡ�
	//    wlan_connection_mode_temporary_profile	��ʹ����ʱ�����ļ��������ӡ�
	//    wlan_connection_mode_discovery_secure	��ȫ���ֽ����ڽ������ӡ�
	//    wlan_connection_mode_discovery_unsecure	��ʹ�ò���ȫ�ķ������������ӡ�
	//    wlan_connection_mode_auto	���߷���ʹ�ó־��������ļ��Զ��������ӡ�
	//    wlan_connection_mode_invalid	
	wlanConnPara.strProfile = wName;
	wlanConnPara.pDot11Ssid = nullptr;	//����ΪNULLʱ����ȥ�����е�ssid
	wlanConnPara.dot11BssType = dot11_BSS_type_infrastructure;	//dot11_BSS_type_any,I do not need it this time.
	wlanConnPara.pDesiredBssidList = nullptr;					// the desired BSSID list is empty
	wlanConnPara.dwFlags = WLAN_CONNECTION_HIDDEN_NETWORK;		//it works on my WIN7\8
	dwResult = WlanConnect(hClientHandle, &guid, &wlanConnPara, NULL);
	delete[] wName;
	return dwResult == ERROR_SUCCESS;
}

bool NativeWifiConnect::passwordToConnectWLAN(const std::string wlanName, const std::string password)
{
	if (!setProfile(wlanName, password))
		return false;
	if (!connectWLAN(wlanName))
		return false;
	return true;
}

bool NativeWifiConnect::disConnect()
{
	dwResult = WlanDisconnect(hClientHandle, &guid, NULL);
	return dwResult == ERROR_SUCCESS;
}

bool NativeWifiConnect::closeWLAN()
{
	if (!disConnect())
		return false;
	WlanFreeMemory(pInterfaceList);//�ͷ��б�/�ͷ��ڴ�,��Native Wifi�������ص��κ��ڴ�����ͷ�
	dwResult = WlanCloseHandle(hClientHandle, nullptr);//�ر�wlan
	return dwResult == ERROR_SUCCESS;
}

bool NativeWifiConnect::setProfile(const std::string wlanName, const std::string password)
{
	std::string strProfile = STR_PROFILE_DEMO;
	stringReplace(strProfile, STR_NAME, wlanName);
	stringReplace(strProfile, STR_PASSWORD, password);
	wchar_t* profile = stringToWideChar(strProfile);
	WLAN_REASON_CODE Wlanreason;
	dwResult = WlanSetProfile(hClientHandle, &guid, 0, profile, NULL, true, NULL, &Wlanreason);
	delete[] profile;
	return dwResult == ERROR_SUCCESS;
}

wchar_t* NativeWifiConnect::stringToWideChar(const std::string pKey)
{
	char* pCStrKey = const_cast<char*>(pKey.c_str());
	//��һ�ε��÷���ת������ַ������ȣ�����ȷ��Ϊwchar_t*���ٶ����ڴ�ռ�
	int pSize = MultiByteToWideChar(CP_OEMCP, 0, pCStrKey, strlen(pCStrKey) + 1, NULL, 0);
	wchar_t *pWCStrKey = new wchar_t[pSize];
	//�ڶ��ε��ý����ֽ��ַ���ת����˫�ֽ��ַ���
	MultiByteToWideChar(CP_OEMCP, 0, pCStrKey, strlen(pCStrKey) + 1, pWCStrKey, pSize);
	return pWCStrKey;
}

void NativeWifiConnect::stringReplace(std::string &inputoutopt, const std::string oldStr, const std::string newStr)
{
	std::string::size_type pos = 0;
	std::string::size_type a = oldStr.size();
	std::string::size_type b = newStr.size();
	while ((pos = inputoutopt.find(oldStr, pos)) != std::string::npos)
	{
		inputoutopt.replace(pos, a, newStr);
		pos += b;
	}
}

std::string NativeWifiConnect::getError()const
{
	std::string str_error = "Various error codes.";
	switch (dwResult)
	{
	case ERROR_SUCCESS:
		str_error = "SUCCESS.";
		break;
	case ERROR_INVALID_PARAMETER:
		str_error = "One of the following conditions occurred:\n"
			"hClientHandle is NULL or invalid.\n"
			"pInterfaceGuid is NULL.\n"
			"pConnectionParameters is NULL.\n"
			"more:https://docs.microsoft.com/zh-cn/windows/win32/api/wlanapi/nf-wlanapi-wlanconnect.";
		break;
	case ERROR_NOT_ENOUGH_MEMORY:
		str_error = "Failed to allocate memory to create the client context.";
		break;
	case ERROR_REMOTE_SESSION_LIMIT_EXCEEDED:
		str_error = "Too many handles have been issued by the server.";
		break;
	case ERROR_INVALID_HANDLE:
		str_error = "The handle hClientHandle was not found in the handle table.";
		break;
	case ERROR_NDIS_DOT11_POWER_STATE_INVALID:
		str_error = "The radio associated with the interface is turned off. There are no available networks when the radio is off.";
		break;
	case ERROR_ACCESS_DENIED:
		str_error = "The caller does not have sufficient permissions.";
		break;
	case ERROR_ALREADY_EXISTS:
		str_error = "strProfileXml specifies a network that already exists.";
		break;
	case ERROR_BAD_PROFILE:
		str_error = "The profile specified by strProfileXml is not valid. If this value is returned, pdwReasonCode specifies the reason the profile is invalid.";
		break;
	case ERROR_NO_MATCH:
		str_error = "The interface does not support one or more of the capabilities specified in the profile.";
		break;
	default:
		str_error = "Various error codes.";
		break;
	}
	return str_error;
}

bool NativeWifiConnect::refreshWLAN(std::map<std::string, int>& wlanMap)
{
	wlanMap.clear();
	dwResult = WlanEnumInterfaces(hClientHandle, nullptr, &pInterfaceList);
	if (dwResult != ERROR_SUCCESS)
	{
		closeWLAN();
		return false;
	}
	for (unsigned int i = 0; i < (int)pInterfaceList->dwNumberOfItems; i++)
	{
		pIfInfo = (WLAN_INTERFACE_INFO *)& pInterfaceList->InterfaceInfo[i];
		guid = pIfInfo->InterfaceGuid;
	}
	dwResult = WlanScan(hClientHandle, &guid, NULL, NULL, NULL);
	if (dwResult != ERROR_SUCCESS)
	{
		return false;
	}
	PWLAN_AVAILABLE_NETWORK_LIST pWLAN_AVAILABLE_NETWORK_LIST = nullptr;
	dwResult = WlanGetAvailableNetworkList(hClientHandle, &guid, 2, nullptr, &pWLAN_AVAILABLE_NETWORK_LIST);
	if (dwResult != ERROR_SUCCESS)
	{
		WlanFreeMemory(pWLAN_AVAILABLE_NETWORK_LIST);
		closeWLAN();
		return false;
	}
	DWORD numberOfItems = pWLAN_AVAILABLE_NETWORK_LIST->dwNumberOfItems;
	WLAN_AVAILABLE_NETWORK wlanAN;
	if (numberOfItems > 0)
	{
		for (DWORD i = 0; i < numberOfItems; i++)
		{
			wlanAN = pWLAN_AVAILABLE_NETWORK_LIST->Network[i];
			char *ssid;
			std::string str_ssid;
			if (wlanAN.dot11Ssid.uSSIDLength != 0)
			{
				ssid = (char*)wlanAN.dot11Ssid.ucSSID;
				str_ssid.append(ssid);
				int wifiQuality = (int)wlanAN.wlanSignalQuality;//�����źŵ�ǿ��
				wlanMap[str_ssid] = wifiQuality;
			}
		}
	}
	return true;
}

bool NativeWifiConnect::queryInterface(std::string &connectedWifi, int& signalQuality)
{
	if (!pIfInfo)
		return false;
	connectedWifi.clear();
	dwResult = WlanEnumInterfaces(hClientHandle, nullptr, &pInterfaceList);
	if (dwResult != ERROR_SUCCESS)
	{
		closeWLAN();
		return false;
	}
	for (unsigned int i = 0; i < (int)pInterfaceList->dwNumberOfItems; i++)
	{
		pIfInfo = (WLAN_INTERFACE_INFO *)& pInterfaceList->InterfaceInfo[i];
		guid = pIfInfo->InterfaceGuid;
	}
	if (pIfInfo->isState == wlan_interface_state_connected)
	{
		char *ssid;
		dwResult = WlanQueryInterface(hClientHandle,
			&guid,
			wlan_intf_opcode_current_connection,
			NULL,
			&connectInfoSize,
			(PVOID *)&pConnectInfo,
			&opCode);
		if (dwResult != ERROR_SUCCESS)	
			return false;
		if (pConnectInfo->wlanAssociationAttributes.dot11Ssid.uSSIDLength != 0)
		{
			ssid = (char*)pConnectInfo->wlanAssociationAttributes.dot11Ssid.ucSSID;
			connectedWifi.append(ssid);
			signalQuality = pConnectInfo->wlanAssociationAttributes.wlanSignalQuality;
		}				
	}
	return true;
}
