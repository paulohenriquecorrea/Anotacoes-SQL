--- REGISTRO 41
--distinct on pra restringir por pessoa
SELECT DISTINCT ON (p.nome_ascii)41 as tipo_registro,NULL as id_aluno_inep,p.nome_ascii AS nome,
                p.cpf_cnpj   AS cpf,
                NULL as  doc_estrangeiro,
                to_char(p.data_nascimento,'DDMMYYYY') as data_nascimento,
                CASE
                    when p.sexo='F' then 1
                    when p.sexo='M' then 0
                 end  AS sexo,
                CASE
                    --mapeamento das raças tabela : comum.tipo_raca    
                    when p.id_raca = -1 then 0
                    when p.id_raca = 1 then 1
                    when p.id_raca = 2 then 3
                    when p.id_raca = 3 then 2
                    when p.id_raca = 4 then 5
                    when p.id_raca = 5 then 4
                    when p.id_raca = 6 then 3
                    else 0
                END as cor_raca,
                ---CORRIGIDO: Translate do nome_mae
                translate( p.nome_mae,  
                'áàâãäåaaaÁÂÃÄÅAAAÀéèêëeeeeeEEEÉEEÈìíîïìiiiÌÍÎÏÌIIIóôõöoooòÒÓÔÕÖOOOùúûüuuuuÙÚÛÜUUUUçÇñÑýÝ',  
                'aaaaaaaaaAAAAAAAAAeeeeeeeeeEEEEEEEiiiiiiiiIIIIIIIIooooooooOOOOOOOOuuuuuuuuUUUUUUUUcCnNyY')
                as nome_completo_mae,
                CASE
                    --Caso seja internacional, entao estrangeiro, senao brasileiro nato
                    when p.internacional then 3
                    else 1
                END as nacionalidade,
                -- id_unidade_federativa  igual ao codigo da unidade
                uf.id_unidade_federativa AS uf_nascimento,
                -- colunada e dados inseridos via script
                mun.codigo_inep as municipio_nascimento,
                case
                    -- cod_pais_pingifes igual ao cod do pais de origem
                    when (ps.cod_pais_pingifes = 'BRA' or uf.id_pais =31 or (not p.internacional)) then 'BRA'
                    else ps.cod_pais_pingifes
                end as pais_origem,
                
                -- pne : tabela feita por join somente com as necessidades mapeadas pelo censo
                -- tabela de registro de necessidades : comum.pessoa_necessidade_especial
                --tabela tipo : comum.tipo_necessidade_especial
                CASE
                    when pne.id_pessoa is not null then 1
                    else 0
                 END as necessidade_especial,
                Case
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 104465551 then 1
                            else 0

                        end
                END as tipo_de_deficiencia_cegueira,
                CASE
                    when pne.id_pessoa is not null then
                        case
                            when pne.id_necessidade_especial = 2 then 1
                            else 0

                        end
                end as tipo_de_deficiente_baixa_visao,
                case
                   when pne.id_pessoa is not null then
                        case
                            when pne.id_necessidade_especial = 103294581 then 1
                            else 0

                        end
                end as tipo_de_deficiencia_surdez,
                CASE
                    when pne.id_pessoa is not null then
                        case
                            when pne.id_necessidade_especial = 1 then 1
                            else 0

                        end
                end as tipo_de_deficiencia_auditiva,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 3 then 1
                            else 0

                        end
                end as tipo_de_deficiente_fisica,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 104465583 then 1
                            else 0
                        end
                end as tipo_de_deficiencia_surdocegueira,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial=4 then 1
                            else 0
                        end
                end as tipo_de_deficiencia_multipla,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 5 then 1
                            else 0
                        end
                end as tipo_de_deficiencia_intelectual,
                CASE
                    when pne.id_pessoa is not null then 0

                end  as  tipo_de_deficiencia_autimo,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 104465575 then 1
                            else 0

                        end
                end as tipo_de_deficiencia_asperger,
                case
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial= 104465582 then 1
                            else 0
                        end
                end as tipo_de_deficiencia_sindromne_de_rett,
                CASE
                    when pne.id_pessoa is not null then 0
                 end  as tipo_de_deficiencia_transt_desintegrativo_infancia,
                CASE
                    when pne.id_pessoa is not null then
                        CASE
                            when pne.id_necessidade_especial = 7 then 1
                            else 0
                        end
                end as tipo_de_deficiencia_super_dotacao

         FROM discente d
         INNER JOIN comum.pessoa p ON d.id_pessoa = p.id_pessoa
         INNER JOIN curso c ON d.id_curso = c.id_curso
         INNER JOIN comum.modalidade_educacao me ON me.id_modalidade_educacao = c.id_modalidade_educacao
         INNER JOIN ensino.forma_ingresso fi ON d.id_forma_ingresso = fi.id_forma_ingresso
         INNER JOIN graduacao.discente_graduacao dg ON d.id_discente = dg.id_discente_graduacao
         INNER JOIN graduacao.matriz_curricular mzc ON dg.id_matriz_curricular = mzc.id_matriz_curricular
         INNER JOIN ensino.turno t ON t.id_turno = mzc.id_turno
         LEFT JOIN comum.campus_ies cmp ON mzc.id_campus = cmp.id_campus
         LEFT JOIN comum.unidade_federativa uf ON p.id_uf_naturalidade = uf.id_unidade_federativa
         LEFT JOIN comum.municipio mun on p.id_municipio_naturalidade = mun.id_municipio
         LEFT JOIN comum.pais ps on p.id_pais_nacionalidade =  ps.id_pais
         LEFT JOIN  (select id_pessoa,id_necessidade_especial from comum.pessoa_necessidade_especial pne2 where pne2.id_necessidade_especial in (104465551,2,103294581,1,3,104465583,4,5,
                                         104465575,104465582,7)) as pne on pne.id_pessoa = p.id_pessoa
        where d.id_discente in (
                -- discentes com registro de matricula em 2019
                -- VERIFICAR as situações de matricula que devem ser consideradas ids: ensino.situacao_matricula
                (select mc3.id_discente from ensino.matricula_componente mc3
                where mc3.ano=2019 and mc3.id_situacao_matricula in (3,4,5,6,7,9,24,25,26,27,10,22,21)  )
                union
                -- discentes com movimentação em 2019
                --ensino.movimentação_aluno
                (select ma3.id_discente from ensino.movimentacao_aluno ma3
                 where ano_referencia=2019 and ma3.id_tipo_movimentacao_aluno in (select id_tipo_movimentacao_aluno from ensino.tipo_movimentacao_aluno tma2
                                                                                  -- VERIFICAR os status dos discentes após a movimentação que devem entrar
                                                                                  -- tabela : public.status_discente
                                                                                  where tma2.statusdiscente in (1,5,6,7,8,9)))
                union
                --discentes cancelados que possuam outros vinculos com ingresso por vagas remanescentes
                (select  id_discente from discente d3 where d3.status=6
                and d3.id_pessoa in (select  d4.id_pessoa from discente d4
                WHERE (d4.ano_ingresso*10+d4.periodo_ingresso)>(d3.ano_ingresso*10+d3.periodo_ingresso)
                and d4.ano_ingresso=2019
                --verficiar forma de ingresso vagas remanescentes
                -- tabela : ensino.forma_ingresso
                and d4.id_forma_ingresso in (63878,63873,63884))))
        --exclusao de discentes com movimentação de de afastamento temporário e permanente com periodo de referencia menor do que 19.1 e sem data de retorno
        and d.id_discente not in (select  ma.id_discente from ensino.movimentacao_aluno ma
                                 inner join ensino.tipo_movimentacao_aluno  tma on ma.id_tipo_movimentacao_aluno = tma.id_tipo_movimentacao_aluno
                                 where (ma.ano_referencia*10+ma.periodo_referencia)<20191
                                 and tma.grupo in ('AP','AT')
                                 and ma.data_retorno is null)
        --exclusao de discentes cancelados que nao possuam registros de matricula maiores ou iguais a 2018
        and d.id_discente not in (SELECT DISTINCT d4.id_discente from discente d4
                                  where  not exists(select id_discente from ensino.matricula_componente mc6
                                                    where (mc6.ano*10+mc6.periodo)>=20182 and mc6.id_discente=d4.id_discente ) and d4.status=6)
        --exclusao de discentes nao cadastrados
        and d.status <> 10
        --filtrando por discentes de graduação
        and d.nivel='G'
        order by p.nome_ascii,d.ano_ingresso desc;
---------------------------------------------------------------------------------------------------------------------------
--42_1
with censo_aluno as (
select p.cpf_cnpj, 42 as tipo_regsitro,
       1 as semestre_referencia,
       --Caso o curso nao tenha o codigo, a matriz possui
       coalesce(c.codigo_inep,mzc.codigo_inep) as codigo_inep,
       CASE
           --Caso o curso seja a distancia, indica a qual polo o curso pertence
          when c.id_modalidade_educacao =2  THEN
             CASE
                 --Códigos retirados da tabela repassada por JADIEL
                 -- Foi verificado que todos os cursos a distancia possuem essse padrão de nome   
                 when  c.id_curso = 64053 then 150222
                 when c.nome ILIKE  '%UAB/CHUPINGUAIA%' then 150222
                 when c.nome ILIKE '%UAB/ROLIM DE MOURA%' then 150225
                 when c.nome ILIKE '%UAB/PORTO VELHO%' then 150136
                 when c.nome ILIKE '%UAB/ARIQUEMES%' then 150216
                 when c.nome ILIKE '%UAB/NOVA MAMORÉ%' then 150224
                 when c.nome ilike  '%UAB/BURITIS%' then 1055971
                 when c.nome ILIKE  '%UAB/JI-PARANÁ%' then 1036751
                 when c.nome ILIKE  '%UAB/JIPARANA%' then 1036751
              END
           END as codigo_polo,
        --matricula : opcional   
        d.matricula as id_ies,
       CASE
           --Quando o curso nao e a distancia, mapeia o turno do curso
           when c.id_modalidade_educacao <> 2 then
                case
                    --tabela de consulta : ensino.turno    
                    --turno 9 : matutino
                    --turno 2 : vespertino
                    -- turno 4 : noturno
                    -- demais turnos possuem mais de um periodo, logo sao considerado integrais    
                    when t.id_turno = 9 then 1
                    when t.id_turno =2 then 2
                    when t.id_turno = 4 then 3
                    else 4
                end

       END as turno_aluno,
       CASE
           --Transferido outro curso da mesma IES
           --Caso o discente esteja Canceclado e possua outro vinculo ligado a ele com ingresso posterior e forma de ingresso por vagas remanescentes
           when d.status = 6 and d.id_pessoa in ( select id_pessoa from discente d2
                                                  where d.id_pessoa = d2.id_pessoa
                                                  --CORRIGIDO : Adicionado clausula pra não pegar mesmo curso
                                                  and d2.id_curso <> d.id_curso
                                                  and (d2.ano_ingresso*10+d2.periodo_ingresso) >(d.ano_ingresso*10+d.periodo_ingresso)
                                                  and (d2.ano_ingresso*10+d2.periodo_ingresso)=20191 and d2.id_forma_ingresso in(63878,63873,63884) ) then 5
           --Falecido
           --Caso o discente possua registro de movimentacao de falecimento no periodo de referencia
           WHEN d.id_discente in (select id_discente from ensino.movimentacao_aluno ma8
                                  where ma8.id_tipo_movimentacao_aluno=3 and ma8.ano_referencia=2019 and ma8.periodo_referencia=1) then 7

           --Formado
           --Caso a ultima integralizacao do discente seja no periodo de referencia, nao exista mais pendencias no curriculo e o discente esteja atualmente FORMADO/CONCLUIDO
           WHEN (select (mc4.ano*10+mc4.periodo) from ensino.matricula_componente mc4
                 where mc4.id_discente = d.id_discente
                 --tabela situacao_matricula
                 and mc4.id_situacao_matricula in (4,24,21,22)
                 order by mc4.ano DESC, mc4.periodo DESC LIMIT 1 )=20191
                --tabela para verificação : graduacao.discente_graduacao
                 and (coalesce((dg.ch_total_pendente+ch_complementar_pendente),0)=0 and d.status in (3,9)) then 6
            --Desvinculado do Curso
            --Caso o usuario tenha movimentacao de afastamento permanente no periodo de referencia ou periodo anterior mas que nao tenha retornado
           WHEN d.id_discente in (select DISTINCT ma2.id_discente from ensino.movimentacao_aluno ma2
                                 where ma2.id_tipo_movimentacao_aluno in (
                                                                          select tma.id_tipo_movimentacao_aluno from ensino.tipo_movimentacao_aluno tma
                                                                          where tma.grupo = 'AP' and tma.statusdiscente not in (3,9) )
                                 and ((ma2.ano_referencia = 2019 and ma2.periodo_referencia=1  )
                                 or (ma2.ano_referencia = 2018 and ma2.periodo_referencia=2 and (ma2.data_retorno is null or ma2.data_retorno>'31-12-2019' ))) ) then 4
           else
                -- Cursando
                -- Caso o discente possua registro de matricula no periodo de referencia
                CASE
                    when d.id_discente in (select DISTINCT id_discente
                                           from ensino.matricula_componente mc where mc.ano=2019 and mc.periodo=1
                                           and  mc.id_situacao_matricula in (4,6,7,9,24,25,26,27,2,22,23,21)) Then 2

                    ELSE
                        CASE
                            --Matricula Trancada
                            --Caso o Discente nao possua registro de matricula do tipo APROVACAO/REPROVAÇÃO e tenha registro de movimentação de trancamento
                            when d.id_discente in (
                                                   (select id_discente from ensino.movimentacao_aluno ma5
                                                    where ma5.id_tipo_movimentacao_aluno in (
                                                                                             select id_tipo_movimentacao_aluno from ensino.tipo_movimentacao_aluno tma3
                                                                                             where tma3.statusdiscente =5)
                                                    and ma5.ano_referencia=2019 and ma5.periodo_referencia=1
                                                        ) )
                                                    -- Revisar conceito de trancamento
                                                    or d.id_discente not in (select id_discente from ensino.matricula_componente mc2 where mc2.id_situacao_matricula in (4,6,7,9,24,25,26) and mc2.ano=2019 and mc2.periodo=1) then 3
                            
                            -- Esse else foi inserido devido a existência de discentes ativos em 2019.1 sem registro de matricula e sem movimentação de trancamento associado. Pode ser revisto                        
                            else 2
                         END

                END
       END  AS situacao_aluno,
       CASE
           --Curso Origem
           --Verifica se o discente possui um vinculo anterior e se ele entrou por seleção de vagas remnescentes
            WHEN exists(select d5.id_discente from discente d5
                        where (d5.ano_ingresso*10+d5.periodo_ingresso) < (d.ano_ingresso*10+d.periodo_ingresso)
                        and d5.status=6
                        and d.id_forma_ingresso in (63878,63873,63884)
                        AND  d.ano_ingresso=2019 ) then
                                                        (select DISTINCT coalesce(nullif(c2.codigo_inep,''),nullif(mzc2.codigo_inep,''))
                                                        from discente d6
                                                        inner join (select d7.id_discente,d7.id_curso from discente d7
                                                                    where d7.id_pessoa=d.id_pessoa
                                                                    and d7.id_discente <> d.id_discente
                                                                    and d7.status=6
                                                                    and (d7.ano_ingresso*10+d7.periodo_ingresso) < (d.ano_ingresso*10+d.periodo_ingresso)   order by d7.ano_ingresso desc,d7.periodo_ingresso desc limit 1 )  as disc_cancelados on disc_cancelados.id_discente=d6.id_discente
                                                        inner join curso c2 ON disc_cancelados.id_curso = c2.id_curso
                                                        inner join graduacao.matriz_curricular mzc2 on c2.id_curso = mzc2.id_curso
                                                        inner join ensino.matricula_componente mc3 on mc3.id_discente= disc_cancelados.id_discente
                                                        where (mc3.ano*10 +mc3.periodo)=20182)

       end as curso_origem,
       case
             -- Quando o discente pertencer a algum curso de licenciatura, verifica se o curso é PARFOR
            when c.id_grau_academico in (5,7,2,6) then
                case
                    when c.nome ilike '%PARFOR%' then 1
                    else 0
                end
       end as aluno_parfor,
        concat('0',d.periodo_ingresso,d.ano_ingresso) as semestre_ingresso,
       CASE

           when p.id_tipo_rede_ensino =1 then 0
           when p.id_tipo_rede_ensino in (2,3,4) then 1
           else 2
       end as tipo_escola_ensino_medio,
       case
            when d.id_forma_ingresso  in (63874,34110) then 1
            else 0
       end as forma_ingresso_vestibular,
       case
           -- Forma de ingressos relacionadas ao enem
           --id_forma_ingresso 
           -- tabela de verificação : ensino.forma_ingresso
            when d.id_forma_ingresso in (63885,1007035,63894,63875,63887,63897,1007039,1007040,1007042,63883,63886,1007045,1007049,1007051,1007053,1007054,1007056) then 1
            else 0
       end as  forma_ingresso_enem,
       CASE
           -- Forma de ingresso 'PROCESSO SELETIVO1'
           when d.id_forma_ingresso = 63900 then 1
           else 0
       end as forma_ingresso_simplificada,
       CASE
           -- Forma de ingresso 'Ex-Officio'
            when d.id_forma_ingresso =  63896 then 1
            else 0
       end  forma_ingresso_ex_officio,
       CASE
            when d.id_forma_ingresso = 34115 then 1
            else 0
       end as  forma_ingresso_judicial,
       CASE
           -- Formas de ingresso para  vagas Remanescentes
          when d.id_forma_ingresso in (1007032,63878,1007033,34113,63882) then 1
           else 0
       end as   forma_ingresso_vagas_remanescentes,
       CASE
           when d.id_forma_ingresso = 90273115 then 1
           else 0
       END as  forma_ingresso_programas_especiais,
       case
           -- mest: tabela feita no join somente com as mobilidades estudantis do tipo externo
           -- tabela : ensino.mobilidade_estudantil 
           WHEN mest.id_discente is not null  and ((mest.ano=2019 and mest.periodo=1) or (mest.ano=2018 and mest.periodo=2 and mest.numero_periodos>1))   then 1
           else 0
       end as mobilidade_academica,
       case
           -- mobilidade_estudantil.subtipo = 1 nacional
           -- mobilidae_estudantil.subtipo = 2 internacional     
           when  mest.subtipo=1 then 1
           when  mest.subtipo=2 then 2
       end as  tipo_mobilidade,
       CASE
          -- Na tabela mobilidade estudantil as ies nao estavam mapeadas, então o mapeamento foi feito de forma estática
          -- verificar preenchimento de mobilidade academica indevido.  
          when mest.ies_externa = 'Universidade Federal de Santa Maria (UFSM)' then 582
          when mest.ies_externa = 'Universidade Tecnológica Federal do Paraná (UTFPR)' then 588
          when mest.ies_externa = 'UNIVERSIDADE FEDERAL DO RIO DE JANEIRO - UFRJ' then 586
       end as ies_destino,
       null as  tipo_mobilidade_internacional,
       null as pais_destino,
       CASE
            --Reserva de vagas : formas de ingresso relacionada a grupos de reservas de vagas
            -- tabela de forma de ingresso : ensino.forma_ingresso
            WHEN d.id_forma_ingresso IN (1007040, 1007042, 63883, 63886, 1007045, 1007049, 1007051, 63894,63875, 63887, 1007039,1007035,1007053,1007054,1007056) THEN 1
            ELSE 0
       END AS programa_reserva_vagas,
       CASE
           -- Verifica se a raça do discente esta dentro dos grupos etnicos e se a forma de ingresso do discente é por reserva de vagas etinico
           WHEN p.id_raca not in (1,5,-1) and d.id_forma_ingresso in (63887,63894,1007035,1007039,1007040,1007042,1007045,1007049,1007051,1007054) THEN 1
           ELSE 0
       END AS reserva_vagas_etnico,
       CASE
           --verifica se o discente possui alguma necessidade especial e se a forma de ingresso dele ta relacionado a reserva de vagas para deficientes 
           -- pne : tabela feita por join somente com as necessidades mapeadas pelo censo
           -- tabela de registro de necessidades : comum.pessoa_necessidade_especial
           --tabela tipo : comum.tipo_necessidade_especial 
           WHEN pne.id_pessoa is not null and d.id_forma_ingresso in (63875,1007035,1007053,1007054,1007056) THEN 1
           ELSE 0
       END AS reserva_vagas_deficiencia,
       CASE
           --Verifica se o discente veio da rede publica e se a forma de ingresso do discente esta relacionado a reserva de vagas para escola publica     
           --CORRIGIDO : mapeamento do tipo de escola publica
            WHEN p.id_tipo_rede_ensino in (2,3,4,5) and d.id_forma_ingresso in (63883,63886,63887,63894,1007035,1007039,1007040,1007042,1007045,1007049,1007051,1007053,1007054,1007056)    THEN 1
           ELSE 0
       END AS reserva_vaga_esc_publica,
       CASE
            -- Verifica a forma de ingresso do discente esta relacionado a reserva de vagas     
            WHEN d.id_forma_ingresso in (1007035,63887,1007039,1007040,1007042,63886,1007053) then 1
            ELSE 0
       END AS reserva_vaga_renda_familiar,
       cur.ch_total_minima as ch_total_aluno_curso,
       (select sum(  ccd.ch_total) from ensino.matricula_componente mc7
        inner join (select DISTINCT ON (id_componente) id_componente_detalhes,ch_total,id_componente from ensino.componente_curricular_detalhes order by  id_componente,data_cadastro desc) ccd on ccd.id_componente =mc7.id_componente_curricular
        --Verificar se as situações de matricula listadas sao todas que geram integraçização
        where mc7.id_situacao_matricula in(4,24,22,23)  and mc7.id_discente =d.id_discente  and (mc7.ano*10+mc7.periodo)<=20191 ) as ch_tot_integ_aluno
       from  discente d
       INNER JOIN comum.pessoa p ON d.id_pessoa = p.id_pessoa
       INNER JOIN curso c ON d.id_curso = c.id_curso
       INNER JOIN comum.modalidade_educacao me ON me.id_modalidade_educacao = c.id_modalidade_educacao
       INNER JOIN graduacao.discente_graduacao dg ON d.id_discente = dg.id_discente_graduacao
       INNER JOIN graduacao.matriz_curricular mzc ON dg.id_matriz_curricular = mzc.id_matriz_curricular
       inner join graduacao.curriculo cur on cur.id_curriculo = d.id_curriculo
       INNER JOIN ensino.turno t ON t.id_turno = mzc.id_turno
       LEFT JOIN comum.campus_ies cmp ON mzc.id_campus = cmp.id_campus
       LEFT JOIN comum.unidade_federativa uf ON p.id_uf_naturalidade = uf.id_unidade_federativa
       left join comum.municipio mun on p.id_municipio_naturalidade = mun.id_municipio
       left join comum.pais ps on p.id_pais_nacionalidade =  ps.id_pais
       LEFT JOIN  (select id_pessoa,id_necessidade_especial from comum.pessoa_necessidade_especial pne2 where pne2.id_necessidade_especial in (104465551,2,103294581,1,3,104465583,4,5,
                                         104465575,104465582,7)) as pne on pne.id_pessoa = p.id_pessoa
       left join (select distinct on (met.id_discente) met.id_discente,met.ano,met.periodo,met.numero_periodos,met.subtipo,met.ies_externa from ensino.mobilidade_estudantil met
                  where  met.ativo and met.tipo=2  order by  met.id_discente,met.ano desc,met.periodo desc ) mest on mest.id_discente = d.id_discente
       LEFT JOIN ead.polo_curso pc on pc.id_curso = c.id_curso
     
     where d.id_discente in (
                           (select mc3.id_discente from ensino.matricula_componente mc3
                            where mc3.ano=2019 and mc3.periodo=1 and mc3.id_situacao_matricula in (3,4,5,6,7,9,24,25,26,27,10,22,21)  )
                           union
                           (select ma3.id_discente from ensino.movimentacao_aluno ma3
                            where ma3.ano_referencia=2019 and ma3.periodo_referencia=1
                            and ma3.id_tipo_movimentacao_aluno in (select id_tipo_movimentacao_aluno from ensino.tipo_movimentacao_aluno tma2
                                                                   where tma2.statusdiscente in (1,5,6,7,8,9)))
                            union
                            (select  id_discente from discente d3
                             where d3.status=6
                             and d3.id_pessoa in (select  d4.id_pessoa from discente d4
                                                  inner join ensino.matricula_componente mc5 on mc5.id_discente = d3.id_discente
                                                  WHERE (d4.ano_ingresso*10+d4.periodo_ingresso)>(d3.ano_ingresso*10+d3.periodo_ingresso)
                                                  and d4.id_curso <> d3.id_curso
                                                  and d4.ano_ingresso=2019
                                                  and d4.periodo_ingresso=1
                                                  and d4.id_forma_ingresso in (63878,63873,63884)
                                                   and (mc5.ano*10+mc5.periodo)=20182)))

     AND d.id_discente NOT IN (SELECT ma.id_discente
                                FROM ensino.movimentacao_aluno ma
                                inner join ensino.tipo_movimentacao_aluno tma4 on ma.id_tipo_movimentacao_aluno = tma4.id_tipo_movimentacao_aluno
                                WHERE (ma.ano_referencia * 10 + ma.periodo_referencia) < 20191
                                and tma4.grupo in ('AP','AT')
                                AND ma.data_retorno IS NULL)
     and d.id_discente not in (SELECT id_discente from discente d4
                               where not  exists(select id_discente from ensino.matricula_componente mc6
                                                 where (mc6.ano*10+mc6.periodo)>=20182
                                                 and mc6.id_discente=d4.id_discente ) and d4.status=6

    )
     and d.nivel='G'
     and d.status <> 10
     and (d.ano_ingresso*10+d.periodo_ingresso)<=20191
     order by p.nome_ascii
    )

 select ca.cpf_cnpj,42 as tipo_registro,1 as semestre_referencia,ca.codigo_inep,ca.codigo_polo,ca.id_ies,
ca.turno_aluno,ca.situacao_aluno,ca.curso_origem, null as semestre_conclusao,ca.aluno_parfor,ca.semestre_ingresso,
ca.tipo_escola_ensino_medio,ca.forma_ingresso_vestibular,ca.forma_ingresso_enem,0 AS forma_ingresso_aval_seriada,
ca.forma_ingresso_simplificada,0 AS forma_ingresso_egresso_bi_li,0  AS forma_ingresso_pec_g,ca.forma_ingresso_ex_officio,
ca.forma_ingresso_judicial,ca.forma_ingresso_vagas_remanescentes,ca.forma_ingresso_programas_especiais,
--Caso o discente esteja na situação 2 ou 6, verifica o campo mobilidade_academica
CASE WHEN ca.situacao_aluno in(2,6) then ca.mobilidade_academica end as mobilidade_academica,
--Caso o discente esteja na situação 2 ou 6 e  o campo da mobilidade academica nao é nulo,verifica o campo tipo_mobilidade
CASE  WHEN ca.mobilidade_academica is not null and ca.situacao_aluno in (2,6) then  ca.tipo_mobilidade end as tipo_mobilidade,
--Caso o discente esteja na situação 2 ou 6, possua mobilidade e a mobilidade seja do tipo externa, verifica a ies_destino
CASE WHEN  ca.mobilidade_academica is not null and ca.tipo_mobilidade = 1 and ca.situacao_aluno in (2,6) then ca.ies_destino end as ies_destino,
null as tipo_mobilidade_internacional,
null as  pais_destino,
ca.programa_reserva_vagas,
-- veririfa as reservas de vagas caso o campo reserva_vagas seja igual a 1
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vagas_etnico end reserva_vagas_etnico,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vagas_deficiencia end reserva_vagas_deficiencia,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vaga_esc_publica end reserva_vaga_esc_publica,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vaga_renda_familiar end  reserva_vaga_renda_familiar,
CASE  when ca.programa_reserva_vagas =1 then 0  end AS reserva_vaga_outros,
NULL  AS financiamento_estudantil,
NULL  AS financiamento_estudantil_fies,
NULL  AS financiamento_estudantil_estadual,
NULL  AS financiamento_estudantil_municipal,
NULL  AS financiamento_estudantil_ies,
NULL  AS financiamento_estudantil_ent_externas,
NULL  AS tipo_financiamento_prouni_integral,
NULL  AS tipo_financiamento_prouni_parcial,
NULL  AS tipo_financiamento_ent_externas,
NULL  AS tipo_financiamento_gov_estadual,
NULL  AS tipo_financiamento_ies,
NULL  AS tipo_financiamento_mun,
--Adicionar Apoio Social(46 a 52)
--Adicionar Atividade Extracurricular (53 a 61)
ca.ch_total_aluno_curso,
coalesce(ca.ch_tot_integ_aluno,0)
       from censo_aluno ca
------------------------------------------------------------------------------------------------------------------
--42_2
with censo_aluno as (
    SELECT p.cpf_cnpj,
           coalesce(c.codigo_inep, mzc.codigo_inep)        AS codigo_inep,
           CASE
               WHEN c.id_modalidade_educacao = 2 THEN
                   CASE
                       WHEN c.id_curso = 64053 THEN 150222
                       WHEN c.nome ILIKE '%UAB/CHUPINGUAIA%' THEN 150222
                       WHEN c.nome ILIKE '%UAB/ROLIM DE MOURA%' THEN 150225
                       WHEN c.nome ILIKE '%UAB/PORTO VELHO%' THEN 150136
                       WHEN c.nome ILIKE '%UAB/ARIQUEMES%' THEN 150216
                       WHEN c.nome ILIKE '%UAB/NOVA MAMORÉ%' THEN 150224
                       WHEN c.nome ILIKE '%UAB/BURITIS%' THEN 1055971
                       WHEN c.nome ILIKE '%UAB/JI-PARANÁ%' THEN 1036751
                       WHEN c.nome ILIKE '%UAB/JIPARANA%' THEN 1036751
                    END
            END  AS codigo_polo,
           d.matricula  AS id_ies,
           CASE
               WHEN c.id_modalidade_educacao <> 2 THEN
                   CASE
                       WHEN t.id_turno = 9 THEN 1
                       WHEN t.id_turno = 2 THEN 2
                       WHEN t.id_turno = 4 THEN 3
                       ELSE 4
                       END
               END                                         AS turno_aluno,
           CASE
               WHEN d.id_discente IN (SELECT id_discente
                                      FROM ensino.movimentacao_aluno ma8
                                      WHERE ma8.id_tipo_movimentacao_aluno = 3
                                        AND ma8.ano_referencia = 2019
                                        AND ma8.periodo_referencia = 2) THEN 7
               WHEN d.status = 6 AND d.id_pessoa IN (SELECT id_pessoa
                                                     FROM discente d2
                                                     WHERE d.id_pessoa = d2.id_pessoa
                                                       AND d.id_curso <> d2.id_curso 
                                                       AND (d2.ano_ingresso * 10 + d2.periodo_ingresso) >
                                                           (d.ano_ingresso * 10 + d.periodo_ingresso)
                                                       AND (d2.ano_ingresso * 10 + d2.periodo_ingresso) = 20201
                                                       AND d2.id_forma_ingresso IN (63878, 63873, 63884)) THEN 5
               WHEN (SELECT (mc4.ano * 10 + mc4.periodo)
                     FROM ensino.matricula_componente mc4
                     WHERE mc4.id_discente = d.id_discente
                       AND mc4.id_situacao_matricula IN (4, 24)
                     ORDER BY mc4.ano DESC, mc4.periodo DESC
                     LIMIT 1) = 20192
                   AND (coalesce((dg.ch_total_pendente + ch_complementar_pendente), 0) = 0 AND d.status IN (3, 9))
                   THEN 6
               WHEN d.id_discente IN (SELECT DISTINCT ma2.id_discente
                                      FROM ensino.movimentacao_aluno ma2
                                      WHERE ma2.id_tipo_movimentacao_aluno IN (SELECT tma.id_tipo_movimentacao_aluno
                                                                               FROM ensino.tipo_movimentacao_aluno tma
                                                                               WHERE tma.grupo = 'AP'
                                                                                 AND tma.statusdiscente NOT IN (3, 9))
                                        AND (
                                              (ma2.ano_referencia = 2019 AND ma2.periodo_referencia = 2 AND
                                               (ma2.data_retorno IS NULL OR ma2.data_retorno > '31-12-2019'))
                                              OR (ma2.ano_referencia = 2019 AND ma2.periodo_referencia = 1 AND
                                                  (ma2.data_retorno IS NULL OR ma2.data_retorno > '31-12-2019'))
                                          )
               ) THEN 4
               ELSE
                   CASE
                       WHEN d.id_discente IN (SELECT DISTINCT id_discente
                                              FROM ensino.matricula_componente mc
                                              WHERE mc.ano = 2019
                                                AND mc.periodo = 2
                                                AND mc.id_situacao_matricula IN (4, 6, 7, 9, 24, 25, 26, 27, 2, 22, 23,21)
                       ) THEN 2

                       ELSE
                           CASE
                               WHEN d.id_discente IN (
                                   (SELECT id_discente
                                    FROM ensino.movimentacao_aluno ma5
                                    WHERE ma5.id_tipo_movimentacao_aluno IN (
                                        SELECT id_tipo_movimentacao_aluno
                                        FROM ensino.tipo_movimentacao_aluno tma3
                                        WHERE tma3.statusdiscente = 5)
                                      AND ma5.ano_referencia = 2019
                                      AND ma5.periodo_referencia = 2
                                   )
                               ) OR d.id_discente NOT IN (SELECT id_discente
                                                          FROM ensino.matricula_componente mc2
                                                          WHERE mc2.id_situacao_matricula IN (4, 6, 7, 9, 24, 25, 26)
                                                            AND mc2.ano = 2019
                                                            AND mc2.periodo = 2) THEN 3
                               ELSE 2
                               END
                       END
               END                                         AS situacao_aluno,
           CASE
               WHEN exists(SELECT d5.id_discente
                           FROM discente d5
                           WHERE (d5.ano_ingresso * 10 + d5.periodo_ingresso) <
                                 (d.ano_ingresso * 10 + d.periodo_ingresso)
                             AND d5.status = 6
                             AND d.id_forma_ingresso IN (63878, 63873, 63884)
                             AND d.ano_ingresso = 2019
                             AND d.periodo_ingresso = 2) THEN (
                   SELECT DISTINCT coalesce(nullif(c2.codigo_inep, ''), nullif(mzc2.codigo_inep, ''))
                   FROM discente d6
                            INNER JOIN (SELECT d7.id_discente, d7.id_curso
                                        FROM discente d7
                                        WHERE d7.id_pessoa = d.id_pessoa
                                          AND d7.id_discente <> d.id_discente
                                          AND d7.id_curso <> d.id_curso
                                          AND d7.status = 6
                                          AND (d7.ano_ingresso * 10 + d7.periodo_ingresso) <
                                              (d.ano_ingresso * 10 + d.periodo_ingresso)
                                        ORDER BY d7.ano_ingresso DESC, d7.periodo_ingresso DESC
                                        LIMIT 1) AS disc_cancelados ON disc_cancelados.id_discente = d6.id_discente
                            INNER JOIN curso c2 ON disc_cancelados.id_curso = c2.id_curso
                            INNER JOIN graduacao.matriz_curricular mzc2 ON c2.id_curso = mzc2.id_curso
                            INNER JOIN ensino.matricula_componente mc3 ON mc3.id_discente = disc_cancelados.id_discente
                   WHERE (mc3.ano * 10 + mc3.periodo) = 20191
               )
               END                                         AS curso_origem,
           CASE
               WHEN c.id_grau_academico IN (5, 7, 2, 6) THEN
                   CASE
                       WHEN c.nome ILIKE '%PARFOR%' AND d.id_forma_ingresso = 90273115 THEN 1
                       ELSE 0
                       END
               END                                         AS aluno_parfor,
           concat('0', d.periodo_ingresso, d.ano_ingresso) AS semestre_ingresso,
           CASE
               WHEN p.id_tipo_rede_ensino = 1 THEN 0
              -- CORRIGIDO : correção do mapeamento do tipo de escola de conclusão do ensino médio
               WHEN p.id_tipo_rede_ensino IN (2, 3, 4,5) THEN 1
               when p.id_tipo_rede_ensino = 1 then 0
               when p.id_tipo_rede_ensino = -1 then 2
               END                                         AS tipo_escola_ensino_medio,
           CASE
               WHEN d.id_forma_ingresso IN (63874, 34110) THEN 1
               ELSE 0
               END                                         AS forma_ingresso_vestibular,
           CASE
               when d.id_forma_ingresso in (63885,1007035,63894,63875,63887,63897,1007039,1007040,1007042,63883,63886,1007045,1007049,1007051,1007053,1007054,1007056) then 1
               ELSE 0
               END                                         AS forma_ingresso_enem,
           CASE
               WHEN d.id_forma_ingresso = 63900 THEN 1
               ELSE 0
               END                                         AS forma_ingresso_simplificada,
           CASE
               WHEN d.id_forma_ingresso = 63896 THEN 1
               ELSE 0
               END                                         AS forma_ingresso_ex_officio,
           CASE
               WHEN d.id_forma_ingresso = 34115 THEN 1
               ELSE 0
               END                                         AS forma_ingresso_judicial,
           CASE
               WHEN d.id_forma_ingresso IN (1007032, 63878, 1007033, 34113, 63882) THEN 1
               ELSE 0
               END                                         AS forma_ingresso_vagas_remanescentes,
           CASE
               WHEN d.id_forma_ingresso = 90273115 THEN 1
               ELSE 0
               END                                         AS forma_ingresso_programas_especiais,
           CASE
               WHEN mest.id_discente IS NOT NULL AND ((mest.ano = 2019 AND mest.periodo = 2) OR (mest.ano = 2019 AND mest.periodo = 1 AND mest.numero_periodos > 1))THEN 1
               ELSE 0
               END                                         AS mobilidade_academica,
           CASE
               WHEN mest.subtipo = 1 THEN 1
               WHEN mest.subtipo = 2 THEN 2
               END                                         AS tipo_mobilidade,
           CASE
               WHEN mest.ies_externa = 'Universidade Federal de Santa Maria (UFSM)' THEN 582
               WHEN mest.ies_externa = 'Universidade Tecnológica Federal do Paraná (UTFPR)' THEN 588
               WHEN mest.ies_externa = 'UNIVERSIDADE FEDERAL DO RIO DE JANEIRO - UFRJ' THEN 586
               END                                         AS ies_destino,
           CASE
               WHEN d.id_forma_ingresso IN
                    (1007040, 1007042, 63883, 63886, 1007045, 1007049, 1007051, 63894, 63875, 63887, 1007039, 1007035,
                     1007053, 1007054, 1007056) THEN 1
               ELSE 0
               END                                         AS programa_reserva_vagas,
           CASE
               WHEN p.id_raca NOT IN (1, 5, -1) AND d.id_forma_ingresso IN
                                                    (63887, 63894, 1007035, 1007039, 1007040, 1007042, 1007045, 1007049,
                                                     1007051, 1007054) THEN 1
               ELSE 0
               END                                         AS reserva_vagas_etnico,
           CASE
               WHEN pne.id_pessoa IS NOT NULL AND d.id_forma_ingresso IN (63875, 1007035, 1007053, 1007054, 1007056)
                   THEN 1
               ELSE 0
           END  AS reserva_vagas_deficiencia,
           CASE
                --CORRIGIDO : correção de mapeamento  dos tipos de escola
               WHEN p.id_tipo_rede_ensino in (2,3,4,5) AND d.id_forma_ingresso IN
                                                  (63883, 63886, 63887, 63894, 1007035, 1007039, 1007040, 1007042,
                                                   1007045, 1007049, 1007051, 1007053, 1007054, 1007056) THEN 1
               ELSE 0
           END as reserva_vaga_esc_publica,
           CASE
               WHEN d.id_forma_ingresso in (1007035,63887,1007039,1007040,1007042,63886,1007053) then 1
               ELSE 0
           END  AS reserva_vaga_renda_familiar,
           cur.ch_total_minima                             AS ch_total_aluno_curso,
           (SELECT sum(ccd.ch_total)
            FROM ensino.matricula_componente mc7
                     INNER JOIN (SELECT DISTINCT ON (id_componente) id_componente_detalhes, ch_total, id_componente
                                 FROM ensino.componente_curricular_detalhes
                                 ORDER BY id_componente, data_cadastro DESC) ccd
                                ON ccd.id_componente = mc7.id_componente_curricular
            WHERE mc7.id_situacao_matricula IN (4, 24, 22, 23)
              AND mc7.id_discente = d.id_discente
              AND (mc7.ano * 10 + mc7.periodo) <= 20192)   AS ch_tot_integ_aluno
    FROM discente d
             INNER JOIN comum.pessoa p ON d.id_pessoa = p.id_pessoa
             INNER JOIN curso c ON d.id_curso = c.id_curso
             INNER JOIN graduacao.discente_graduacao dg ON d.id_discente = dg.id_discente_graduacao
             INNER JOIN graduacao.matriz_curricular mzc ON dg.id_matriz_curricular = mzc.id_matriz_curricular
             INNER JOIN graduacao.curriculo cur ON cur.id_curriculo = d.id_curriculo
             INNER JOIN ensino.turno t ON t.id_turno = mzc.id_turno
             LEFT JOIN comum.campus_ies cmp ON mzc.id_campus = cmp.id_campus
             LEFT JOIN comum.unidade_federativa uf ON p.id_uf_naturalidade = uf.id_unidade_federativa
             LEFT JOIN comum.municipio mun ON p.id_municipio_naturalidade = mun.id_municipio
             LEFT JOIN comum.pais ps ON p.id_pais_nacionalidade = ps.id_pais
             LEFT JOIN (SELECT id_pessoa, id_necessidade_especial
                        FROM comum.pessoa_necessidade_especial pne
                        WHERE pne.id_necessidade_especial IN (104465551, 2, 103294581, 1, 3, 104465583, 4, 5,
                                                              104465575, 104465582, 7)) AS pne
                       ON pne.id_pessoa = p.id_pessoa
             LEFT JOIN (SELECT DISTINCT ON (met.id_discente) met.id_discente,
                                                             met.ano,
                                                             met.periodo,
                                                             met.numero_periodos,
                                                             met.subtipo,
                                                             met.ies_externa
                        FROM ensino.mobilidade_estudantil met
                        WHERE met.ativo
                          AND met.tipo = 2
                        ORDER BY met.id_discente, met.ano DESC, met.periodo DESC) mest
                       ON mest.id_discente = d.id_discente
             LEFT JOIN ead.polo_curso pc ON pc.id_curso = c.id_curso
    WHERE d.id_discente IN (
        (SELECT mc3.id_discente
         FROM ensino.matricula_componente mc3
         WHERE mc3.ano = 2019
           AND mc3.periodo = 2
           AND mc3.id_situacao_matricula IN (3, 4, 5, 6, 7, 9, 24, 25, 26, 27, 10,21,22))
        UNION
        (SELECT ma3.id_discente
         FROM ensino.movimentacao_aluno ma3
         WHERE ma3.ano_referencia = 2019
           AND ma3.periodo_referencia = 2
           
           AND ma3.id_tipo_movimentacao_aluno IN (SELECT id_tipo_movimentacao_aluno
                                                  FROM ensino.tipo_movimentacao_aluno tma2
                                                  WHERE tma2.statusdiscente IN (1, 5, 6, 7, 8, 9))
           AND (ma3.data_retorno IS NULL OR ma3.data_retorno > '31-12-2019'))
        UNION
        (SELECT id_discente
         FROM discente d3
         WHERE d3.status = 6
           AND d3.id_pessoa IN (SELECT d4.id_pessoa
                                FROM discente d4
                                         INNER JOIN ensino.matricula_componente mc5 ON mc5.id_discente = d3.id_discente
                                WHERE (d4.ano_ingresso * 10 + d4.periodo_ingresso) >
                                      (d3.ano_ingresso * 10 + d3.periodo_ingresso)
                                  AND d4.ano_ingresso = 2019
                                  AND d4.periodo_ingresso = 2
                                  AND d4.id_curso <> d3.id_curso
                                  AND d4.id_forma_ingresso IN (63878, 63873, 63884)
                                  AND (mc5.ano * 10 + mc5.periodo) = 20191))
    )
      AND d.id_discente NOT IN (SELECT ma.id_discente
                                FROM ensino.movimentacao_aluno ma
                                         INNER JOIN ensino.tipo_movimentacao_aluno tma4
                                                    ON ma.id_tipo_movimentacao_aluno = tma4.id_tipo_movimentacao_aluno
                                WHERE (ma.ano_referencia * 10 + ma.periodo_referencia) < 20191
                                  AND tma4.grupo IN ('AP', 'AT')
                                  AND ma.data_retorno IS NULL)
      AND d.id_discente NOT IN (SELECT id_discente
                                FROM discente d4
                                WHERE NOT exists(SELECT id_discente
                                                 FROM ensino.matricula_componente mc6
                                                 WHERE (mc6.ano * 10 + mc6.periodo) >= 20182
                                                   AND mc6.id_discente = d4.id_discente)
                                  AND d4.status = 6)
      -- Filtro para evitar os registros formados em 19.1 aparecendo em 19.2
      AND d.id_discente NOT IN ((SELECT ma4.id_discente
                                 FROM ensino.movimentacao_aluno ma4
                                 WHERE ma4.ano_referencia = 2019
                                 --tipo da movimentação concluido 
                                   AND ma4.id_tipo_movimentacao_aluno = 1
                                   AND ma4.periodo_referencia = 1)
                                INTERSECT
                                (SELECT id_discente
                                 FROM ensino.movimentacao_aluno ma6
                                 -- tipo da movimentação de integralização
                                 WHERE ma6.id_tipo_movimentacao_aluno = 315
                                   AND ma6.ano_referencia = 2019
                                   AND ma6.periodo_referencia = 2))

      AND d.nivel = 'G'
      AND d.status <> 10
      AND (d.ano_ingresso * 10 + d.periodo_ingresso) <= 20192

    ORDER BY p.nome_ascii
)
select ca.cpf_cnpj,42 as tipo_registro,2 as semestre_referencia,ca.codigo_inep,ca.codigo_polo,ca.id_ies,
ca.turno_aluno,ca.situacao_aluno,ca.curso_origem, null as semestre_conclusao,ca.aluno_parfor,ca.semestre_ingresso,
ca.tipo_escola_ensino_medio,ca.forma_ingresso_vestibular,ca.forma_ingresso_enem,0 AS forma_ingresso_aval_seriada,
ca.forma_ingresso_simplificada,0 AS forma_ingresso_egresso_bi_li,0  AS forma_ingresso_pec_g,ca.forma_ingresso_ex_officio,
ca.forma_ingresso_judicial,ca.forma_ingresso_vagas_remanescentes,ca.forma_ingresso_programas_especiais,

CASE WHEN ca.situacao_aluno in(2,6) then ca.mobilidade_academica end as mobilidade_academica,

CASE  WHEN ca.mobilidade_academica is not null and ca.situacao_aluno in (2,6) then  ca.tipo_mobilidade end as tipo_mobilidade,

CASE WHEN  ca.mobilidade_academica is not null and ca.tipo_mobilidade = 1 and ca.situacao_aluno in (2,6) then ca.ies_destino end as ies_destino,

null as tipo_mobilidade_internacional,
null as  pais_destino,
ca.programa_reserva_vagas,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vagas_etnico end reserva_vagas_etnico,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vagas_deficiencia end reserva_vagas_deficiencia,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vaga_esc_publica end reserva_vaga_esc_publica,
CASE  WHEN ca.programa_reserva_vagas =1 then ca.reserva_vaga_renda_familiar end  reserva_vaga_renda_familiar,
CASE  when ca.programa_reserva_vagas =1 then 0  end AS reserva_vaga_outros,
NULL  AS financiamento_estudantil,
NULL  AS financiamento_estudantil_fies,
NULL  AS financiamento_estudantil_estadual,
NULL  AS financiamento_estudantil_municipal,
NULL  AS financiamento_estudantil_ies,
NULL  AS financiamento_estudantil_ent_externas,
NULL  AS tipo_financiamento_prouni_integral,
NULL  AS tipo_financiamento_prouni_parcial,
NULL  AS tipo_financiamento_ent_externas,
NULL  AS tipo_financiamento_gov_estadual,
NULL  AS tipo_financiamento_ies,
NULL  AS tipo_financiamento_mun,
ca.ch_total_aluno_curso,
coalesce(ca.ch_tot_integ_aluno,0)
       from censo_aluno ca


