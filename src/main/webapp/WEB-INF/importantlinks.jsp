<%-- importantlinks.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    /* Resources & Links Section Styling */
    .important-links-container {
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(10px);
        border-radius: 25px;
        padding: 35px;
        margin: 20px auto 40px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        border: 1px solid rgba(255, 255, 255, 0.3);
        animation: fadeIn 0.6s ease;
        max-width: 1400px;
        width: calc(100% - 60px);
    }
    
    .important-links-header {
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    }
    
    .important-links-title {
        font-size: 1.8rem;
        font-weight: 700;
        color: #003d7a;
        position: relative;
        padding-left: 20px;
        font-family: 'Poppins', sans-serif;
        margin: 0;
    }
    
    .important-links-title::before {
        content: '';
        position: absolute;
        left: 0;
        top: 5px;
        height: 80%;
        width: 8px;
        background: linear-gradient(to bottom, #3a7fc5, #0056b3);
        border-radius: 4px;
    }
    
    /* Important Links Grid */
    .important-links-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px;
        margin-top: 20px;
    }
    
    .important-link {
        background: linear-gradient(135deg, #0056b3, #3a7fc5);
        color: white;
        text-align: center;
        padding: 25px 15px;
        border-radius: 15px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 12px;
        font-family: 'Poppins', sans-serif;
        min-height: 140px;
    }
    
    .important-link i {
        font-size: 1.8rem;
        margin-bottom: 5px;
    }
    
    .important-link span {
        font-size: 0.95rem;
        line-height: 1.4;
    }
    
    .important-link:hover {
        transform: translateY(-5px) scale(1.03);
        box-shadow: 0 12px 25px rgba(0, 0, 0, 0.2);
        background: linear-gradient(135deg, #003d7a, #0056b3);
    }
    
    /* Animation */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* Responsive adjustments */
    @media (max-width: 1200px) {
        .important-links-grid {
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        }
    }
    
    @media (max-width: 992px) {
        .important-links-container {
            padding: 25px;
            width: calc(100% - 40px);
        }
        
        .important-links-title {
            font-size: 1.6rem;
        }
        
        .important-links-grid {
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 15px;
        }
    }
    
    @media (max-width: 768px) {
        .important-links-container {
            padding: 20px;
            width: calc(100% - 30px);
            margin: 15px auto 30px;
        }
        
        .important-links-title {
            font-size: 1.4rem;
            padding-left: 15px;
        }
        
        .important-links-title::before {
            width: 6px;
        }
        
        .important-links-grid {
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 12px;
        }
        
        .important-link {
            padding: 20px 10px;
            min-height: 120px;
        }
        
        .important-link i {
            font-size: 1.5rem;
        }
        
        .important-link span {
            font-size: 0.85rem;
        }
    }
    
    @media (max-width: 576px) {
        .important-links-grid {
            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
        }
    }
</style>

<div class="important-links-container">
    <div class="important-links-header">
        <h3 class="important-links-title">Resources &amp; Links</h3>
    </div>
    
    <div class="important-links-grid">
        <a href="https://indianrailways.gov.in/" class="important-link" target="_blank">
            <i class="fas fa-search"></i>
            <span>Indian Railways</span>
        </a>
        <a href="https://nwr.indianrailways.gov.in/" class="important-link" target="_blank">
            <i class="fas fa-train"></i>
            <span>NWR</span>
        </a>
        <a href="https://services.eoffice.gov.in" class="important-link" target="_blank">
            <i class="fas fa-file-signature"></i>
            <span>eOffice</span>
        </a>
        <a href="https://aims.indianrailways.gov.in/IPAS/LoginForms/Login.jsp" class="important-link" target="_blank">
            <i class="fas fa-rupee-sign"></i>
            <span>IPAS</span>
        </a>
        <a href="https://parichay.nic.in/pnv1/assets/login?sid=SPARROWMINRAIL" class="important-link" target="_blank">
            <i class="fas fa-user-tie"></i>
            <span>SPARROW</span>
        </a>
        <a href="https://www.ireps.gov.in/" class="important-link" target="_blank">
            <i class="fas fa-shopping-cart"></i>
            <span>IREPS</span>
        </a>
        <a href="https://ircep.gov.in/IRPSM/" class="important-link" target="_blank">
            <i class="fas fa-ticket-alt"></i>
            <span>IRPSM</span>
        </a>
        <a href="https://email.gov.in/" class="important-link" target="_blank">
            <i class="fas fa-envelope"></i>
            <span>NIC Mail</span>
        </a>
        <a href="https://gem.gov.in/" class="important-link" target="_blank">
            <i class="fas fa-store"></i>
            <span>GeM</span>
        </a>
        <a href="https://hrms.indianrail.gov.in/HRMS/" class="important-link" target="_blank">
            <i class="fas fa-file-contract"></i>
            <span>HRMS</span>
        </a>
        <a href="<%= request.getContextPath() %>/downloads/telephone-directory.pdf" class="important-link" target="_blank">
            <i class="fas fa-phone-alt"></i>
            <span>Telephone Directory</span>
        </a>
    </div>
</div>