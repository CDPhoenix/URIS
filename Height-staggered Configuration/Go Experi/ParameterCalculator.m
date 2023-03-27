classdef ParameterCalculator
    
    methods(Static)
        function Nu = NusseltNumber_cal(q,T,T_ref,H,k)
            h = ParameterCalculator.convcof_cal(q,T,T_ref);
            Nu = h*H/k;
        end

        function Re = Reynolds_cal(U,Lsc,Kv)

            if size(Kv,2)>1
                Kv = Kv(:,end);
                Kv = Kv(~isnan(Kv));
                Kv = mean(Kv(:,1));
            end
            Re = U*Lsc./Kv;
        end

        function h = convcof_cal(q,T,T_ref)
            if size(T,2)>1 || size(q,2)>1
                q = q(:,end);
                T = T(:,end);
            end
    
            T_delta = T - T_ref;
            h = q./T_delta;
            h = mean(h(:,1));
        end
    end
end