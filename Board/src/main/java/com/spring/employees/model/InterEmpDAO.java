package com.spring.employees.model;

import java.util.List;
import java.util.Map;

public interface InterEmpDAO {

	// employees 테이블에서 근무중인 사원들의 부서번호 가져오기
	List<String> deptIdList();

	// employees 테이블에서 조건에 만족하는 사원들을 가져오기
	List<Map<String, String>> empList(Map<String, String> paraMap);

}
