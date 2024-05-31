#pragma once

#define _WIN32_WINNT 0x0501
#include <windows.h>
#include <wlanapi.h>
#include <map>
#include <string>

//#ifdef NATIVE_WIFI_CONNECT_EXPORTS
//#define NATIVE_WIFI_CONNECT_API __declspec(dllexport)
//#else
//#define NATIVE_WIFI_CONNECT_API __declspec(dllimport)
//#endif /* NATIVE_WIFI_CONNECT_EXPORTS */

class NativeWifiConnect
{
public:
	NativeWifiConnect();
	~NativeWifiConnect();

	/*func �򿪲����������б�
	@param wlanMap ���������б�key-��������value-�ź�ǿ��
	@return �ɹ�����true,ʧ�ܷ���false	*/
	bool  openWLAN(std::map<std::string, int> &wlanMap);

	/*func ֱ�������ѱ���������Wifi
	@return �ɹ�����true,ʧ�ܷ���false	*/
	bool  connectWLAN(const std::string wlanName);

	/*func ͨ��������������
	@return �ɹ�����true,ʧ�ܷ���false	*/
	bool  passwordToConnectWLAN(const std::string wlanName, const std::string password);

	/*func ˢ������
	@param wlanMap ���������б�key-��������value-�ź�ǿ��
	@return �ɹ�����true,ʧ�ܷ���false	*/
	bool  refreshWLAN(std::map<std::string, int> &wlanMap);

	/*func ��ѯ��ǰ��������
	@param connectedWifi ��ǰ����������.����ǰδ�������磬��ֵΪ�ա�
	@param signalQuality ��ǰ���������ź�ǿ��
	@return ��ѯ�ɹ�����true,ʧ�ܷ���false	*/
	bool  queryInterface(std::string &connectedWifi,int& signalQuality);

	bool  disConnect();
	bool  closeWLAN();
	std::string getError()const;
private:
	//��Ҫ������ʹ����wchar_t*��delete[]�ͷ��ڴ�
	wchar_t*  stringToWideChar(const std::string pKey);

	bool  setProfile(const std::string wlanName, const std::string password);
	void  stringReplace(std::string &inputoutput, const std::string oldStr, const std::string newStr);

	HANDLE hClientHandle = NULL;
	GUID guid;
	// variables used for WlanEnumInterfaces
	PWLAN_INTERFACE_INFO_LIST  pInterfaceList=NULL;
	PWLAN_INTERFACE_INFO pIfInfo = NULL;

	// variables used for WlanQueryInterfaces for opcode = wlan_intf_opcode_current_connection
	PWLAN_CONNECTION_ATTRIBUTES pConnectInfo = NULL;
	DWORD connectInfoSize;
	WLAN_OPCODE_VALUE_TYPE opCode;

	DWORD dwResult = 0;
	std::string STR_NAME;
	std::string STR_PASSWORD;
	std::string STR_PROFILE_DEMO;
};
